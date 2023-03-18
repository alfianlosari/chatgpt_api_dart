import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chatgpt_client/src/message.dart';

class ChatGPTClient {
  final url = Uri.https("api.openai.com", "/v1/chat/completions");
  final String apiKey;
  final String model;
  final String systemPrompt;
  final double temperature;

  List<Message> _historyList = List.empty(growable: true);
  final _client = http.Client();

  ChatGPTClient(
      {required this.apiKey,
      this.model = "gpt-3.5-turbo",
      this.systemPrompt = "You are a helpful assistant",
      this.temperature = 0.5});

  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey"
    };
  }

  String _getBody(String text, bool stream) {    
    final body = {
      "model": model,
      "temperature": temperature,
      "messages": _generateMessages(text).map((e) => e.toMap()).toList(),
      "stream": stream
    };
    return jsonEncode(body);
  }

  List<Message> _generateMessages(String prompt) {
    var messages = [_getSystemMessage()] + _historyList + [Message(content: prompt, role: "user")];
    final messagesContentCount = messages.map((e) => e.content.length)
                   .reduce((value, element) => value + element);
    if (messagesContentCount > (4000 * 4)) {
        _historyList.removeAt(0);
        messages = _generateMessages(prompt);
    }     
    return messages;                           
  }

  void _appendToHistoryList(String userText, String responseText) {
    _historyList.addAll([
      Message(content: userText, role: "user"),
      Message(content: responseText, role: "assistant")
    ]);
  }

  Message _getSystemMessage() {
    return Message(content: systemPrompt, role: "system");
  }

  Future<String> sendMessage(String text) async {
      final response = await _client.post(url,
          headers: _getHeaders(), body: _getBody(text, false));
      
      dynamic decodedResponse;
      if (response.contentLength != null) {
        decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      }

      final statusCode = response.statusCode;    
      if (!(statusCode >= 200 && statusCode < 300)) {
        if (decodedResponse != null) {
          final errorMessage = decodedResponse["error"]["message"] as String;
          throw Exception("($statusCode) $errorMessage");
        }
        throw Exception("($statusCode) Bad response ${response.reasonPhrase ?? ""}");
      }
      
      final choices = decodedResponse["choices"] as List;
      final choice = choices[0] as Map;
      final content = choice["message"]["content"] as String;
      _appendToHistoryList(text, content);
      return content;
  }

  Stream<String> sendMessageStream(String text) async* {
      final request = http.Request("POST", url)
          ..headers.addAll(_getHeaders());
      request.body = _getBody(text, true);      

      final responseStream = await request.send();
      final statusCode = responseStream.statusCode;
      final byteStream = responseStream.stream;

      if (!(statusCode >= 200 && statusCode < 300)) {
        var error = "";
        await for (final byte in byteStream) {
            final decoded = utf8.decode(byte).trim();
            final map = jsonDecode(decoded) as Map;
            final errorMessage = map["error"]["message"] as String;
            error += errorMessage;
        }
        throw Exception("($statusCode) ${error.isEmpty ? "Bad Response" : error}");
      }

      var responseText = "";
      await for (final byte in byteStream) {
        var decoded = utf8.decode(byte).trim();  
        if (decoded.startsWith("data: ") && !decoded.endsWith("data: [DONE]")) {          
            decoded = decoded.replaceFirst("data: ", "").trim();
            final map = jsonDecode(decoded) as Map;
            final choices = map["choices"] as List;
            final delta = choices[0]["delta"] as Map;
            if (delta["content"] != null) {
              final content = delta["content"] as String;
              responseText += content;
              yield content;
            }  
        }
    }

    if (responseText.isNotEmpty) {
      _appendToHistoryList(text, responseText);
    }
  }

  void clearHistoryList() {
    _historyList = List.empty(growable: true);
  }
}

