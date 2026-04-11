import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../security/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  bool _isRefreshing = false;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
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
    if (_isRefreshing) return null;
    _isRefreshing = true;
    try {
      final currentToken = await _secureStorage.getAccessToken();
      if (currentToken == null) return null;

      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      ));
      final response = await dio.post(ApiConstants.refreshToken);

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        if (newToken != null) {
          await _secureStorage.setAccessToken(newToken);
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          return await dio.fetch(requestOptions);
        }
      }
    } catch (_) {
    } finally {
      _isRefreshing = false;
    }
    return null;
  }
}
