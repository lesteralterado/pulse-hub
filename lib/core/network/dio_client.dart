import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import '../utils/app_logger.dart';

/// Shared Dio instance + error mapping for the non-Supabase HTTP calls the
/// app makes (e.g. future CaryPact/BOT Chain indexer APIs). Supabase's own
/// client manages its own networking and does not go through this class.
class DioClient {
  DioClient({required String baseUrl, Duration? timeout})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: timeout ?? const Duration(seconds: 15),
            receiveTimeout: timeout ?? const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.debug('-> ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
            '<- ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error('x ${error.requestOptions.uri}', error);
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;

  /// Converts a raw [DioException] into an [AppException] the rest of the
  /// app knows how to handle uniformly.
  static AppException mapError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          'Could not reach the server: ${error.message}',
          cause: error,
        );
      case DioExceptionType.badCertificate:
        return NetworkException('Invalid server certificate', cause: error);
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled');
      case DioExceptionType.badResponse:
        return ServerException(
          'Server returned an error response',
          cause: error,
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.unknown:
      default:
        return UnknownException(
          'Unexpected network error: ${error.message}',
          cause: error,
        );
    }
  }
}
