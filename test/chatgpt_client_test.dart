import 'package:chatgpt_client/chatgpt_client.dart';

void main() async {
   final client = ChatGPTClient(apiKey: "API_KEY");
   final prompt = "What is ChatGPT?";
   /// Standard Response
   print("Standard Response");
   try {
      final text = await client.sendMessage(prompt);
      print(text);
    } catch (exception) {
      print(exception.toString());
    }

    /// Stream Response
    print("Stream Response");
    try {
      var text = "";
      final stream = client.sendMessageStream(prompt);
      await for (final textChunk in stream) {
          text += textChunk;
          print(textChunk);
      }
      print(text);
    } catch (exception) {
      print(exception.toString());
    }

    client.clearHistoryList();
}
