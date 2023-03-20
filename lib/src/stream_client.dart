import 'package:http/http.dart';
import 'stream_client_stub.dart'
    if (dart.library.io) 'stream_client_native.dart'
    if (dart.library.js) 'stream_client_web.dart';

abstract class StreamClient {
  static StreamClient instance = getClient();

  Future<StreamedResponse> send(BaseRequest request);
}
