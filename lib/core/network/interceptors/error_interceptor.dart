import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(message: 'Tempo de conexão esgotado'),
            type: err.type,
          ),
        );
        return;
      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(),
            type: err.type,
          ),
        );
        return;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;

        if (statusCode == 401) {
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: const AuthException(),
              response: err.response,
              type: err.type,
            ),
          );
          return;
        }

        if (statusCode == 422 && data is Map<String, dynamic>) {
          final errors = <String, List<String>>{};
          if (data['errors'] != null) {
            (data['errors'] as Map<String, dynamic>).forEach((key, value) {
              errors[key] = (value as List).map((e) => e.toString()).toList();
            });
          }
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: ValidationException(
                message: data['message']?.toString() ?? 'Erro de validação',
                fieldErrors: errors,
              ),
              response: err.response,
              type: err.type,
            ),
          );
          return;
        }

        if (statusCode == 429) {
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: const ServerException(
                message: 'Muitas requisições. Tente novamente em instantes.',
                statusCode: 429,
              ),
              response: err.response,
              type: err.type,
            ),
          );
          return;
        }

        final message = data is Map ? (data['message']?.toString() ?? 'Erro no servidor') : 'Erro no servidor';
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(message: message, statusCode: statusCode),
            response: err.response,
            type: err.type,
          ),
        );
        return;
      default:
        handler.next(err);
    }
  }
}
