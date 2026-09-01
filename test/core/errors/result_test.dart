import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success reports isSuccess/isFailure correctly', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
    });

    test('Failure reports isSuccess/isFailure correctly', () {
      const result = Result<int>.failure(NetworkException('offline'));

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('when() dispatches to the success branch for Success', () {
      const result = Result<String>.success('hello');

      final output = result.when(
        success: (value) => 'got: $value',
        failure: (error) => 'error: ${error.message}',
      );

      expect(output, 'got: hello');
    });

    test('when() dispatches to the failure branch for Failure', () {
      const result = Result<String>.failure(
        ServerException('bad request', statusCode: 400),
      );

      final output = result.when(
        success: (value) => 'got: $value',
        failure: (error) => 'error: ${error.message}',
      );

      expect(output, 'error: bad request');
    });

    test('ServerException carries its status code through when()', () {
      const result = Result<String>.failure(
        ServerException('server exploded', statusCode: 500),
      );

      final statusCode = result.when(
        success: (_) => null,
        failure: (error) => (error as ServerException).statusCode,
      );

      expect(statusCode, 500);
    });
  });
}
