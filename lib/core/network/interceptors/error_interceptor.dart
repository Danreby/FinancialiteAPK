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
            error: const NetworkException(message: 'Sem conexão com a internet. Verifique sua rede.'),
            type: err.type,
          ),
        );
        return;
      case DioExceptionType.badCertificate:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(message: 'Erro de certificado SSL. Verifique sua conexão.'),
            type: err.type,
          ),
        );
        return;
      case DioExceptionType.cancel:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const ServerException(message: 'Requisição cancelada'),
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
          final msg = data is Map
              ? (data['error']?.toString() ?? data['message']?.toString() ?? 'Muitas requisições. Tente novamente em instantes.')
              : 'Muitas requisições. Tente novamente em instantes.';
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: ServerException(message: msg, statusCode: 429),
              response: err.response,
              type: err.type,
            ),
          );
          return;
        }

        String message;
        if (data is Map) {
          message = data['error']?.toString() ?? data['message']?.toString() ?? 'Erro no servidor ($statusCode)';
        } else if (data is String && data.isNotEmpty && !data.startsWith('<!')) {
          message = data;
        } else {
          message = 'Erro no servidor ($statusCode)';
        }
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
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(
              message: err.message ?? 'Erro inesperado de conexão',
            ),
            type: err.type,
          ),
        );
    }
  }
}
