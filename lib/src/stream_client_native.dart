import 'package:http/http.dart' as http;
import 'stream_client.dart';

class StreamClientNative extends StreamClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return http.Client().send(request);
  }
}

StreamClient getClient() => StreamClientNative();
