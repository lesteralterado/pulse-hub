import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/network/dio_client.dart';

DioException _errorOf(DioExceptionType type, {Response? response}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    response: response,
  );
}

void main() {
  group('DioClient.mapError', () {
    test('connection timeout maps to NetworkException', () {
      final result = DioClient.mapError(
        _errorOf(DioExceptionType.connectionTimeout),
      );

      expect(result, isA<NetworkException>());
    });

    test('connection error maps to NetworkException', () {
      final result = DioClient.mapError(
        _errorOf(DioExceptionType.connectionError),
      );

      expect(result, isA<NetworkException>());
    });

    test('cancel maps to NetworkException', () {
      final result = DioClient.mapError(_errorOf(DioExceptionType.cancel));

      expect(result, isA<NetworkException>());
    });

    test('bad response maps to ServerException carrying the status code', () {
      final response = Response<void>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 404,
      );

      final result = DioClient.mapError(
        _errorOf(DioExceptionType.badResponse, response: response),
      );

      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 404);
    });

    test('unknown type maps to UnknownException', () {
      final result = DioClient.mapError(_errorOf(DioExceptionType.unknown));

      expect(result, isA<UnknownException>());
    });
  });
}
