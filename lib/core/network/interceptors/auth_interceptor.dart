import 'package:dio/dio.dart';
import '../../security/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken(err.requestOptions);
      if (refreshed != null) {
        handler.resolve(refreshed);
        return;
      }
      await _secureStorage.clearAll();
    }
    handler.next(err);
  }

  Future<Response?> _tryRefreshToken(RequestOptions requestOptions) async {
    try {
      final currentToken = await _secureStorage.getAccessToken();
      if (currentToken == null) return null;

      final dio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
      final response = await dio.post(
        '/auth/refresh-token',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        if (newToken != null) {
          await _secureStorage.setAccessToken(newToken);
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          return await dio.fetch(requestOptions);
        }
      }
    } catch (_) {}
    return null;
  }
}
