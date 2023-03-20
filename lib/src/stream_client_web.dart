import 'package:http/http.dart' as http;
import 'stream_client.dart';
import 'package:fetch_client/fetch_client.dart';

class StreamClientWeb extends StreamClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final client = FetchClient(mode: RequestMode.cors, streamRequests: true);
    return client.send(request);
  }
}

StreamClient getClient() => StreamClientWeb();
