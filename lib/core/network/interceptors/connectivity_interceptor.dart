import 'package:dio/dio.dart';
import '../network_info.dart';
import '../../error/exceptions.dart';

class ConnectivityInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;

  ConnectivityInterceptor(this._networkInfo);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: const NetworkException(),
            type: DioExceptionType.connectionError,
          ),
        );
        return;
      }
    } catch (_) {
      // If connectivity check itself fails, assume connected and let Dio handle errors
    }
    handler.next(options);
  }
}
