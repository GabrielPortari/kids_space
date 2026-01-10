import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

NetworkException mapDioException(DioException e) {
  final status = e.response?.statusCode;
  String msg;

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      msg = 'Connection timed out';
      break;
    case DioExceptionType.badResponse:
      msg = 'Server error: ${status ?? 'unknown'}';
      break;
    case DioExceptionType.cancel:
      msg = 'Request was cancelled';
      break;
    case DioExceptionType.unknown:
    case DioExceptionType.connectionError:
    default:
      msg = e.message ?? 'Network error';
  }

  return NetworkException(msg, statusCode: status);
}
