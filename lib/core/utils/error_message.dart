import 'dart:async';
import 'package:dio/dio.dart';

import '../error/exceptions.dart';

String extractErrorMessage(Object error) {
  if (error is TimeoutException) {
    return 'Tempo de conexão esgotado. Verifique sua internet.';
  }
  if (error is ValidationException) {
    if (error.fieldErrors != null && error.fieldErrors!.isNotEmpty) {
      return error.fieldErrors!.values.expand((v) => v).join('\n');
    }
    return error.message;
  }
  if (error is NetworkException) return error.message;
  if (error is AuthException) return error.message;
  if (error is ServerException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'] as String;
    }
    return error.response?.statusMessage ?? 'Erro inesperado. Tente novamente.';
  }
  if (error is Exception) {
    return error.toString().replaceAll(RegExp(r'^\w+Exception:\s*'), '');
  }
  return 'Erro inesperado. Tente novamente.';
}
