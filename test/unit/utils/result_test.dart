import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisnap/core/utils/result.dart';

void main() {
  group('Result Utility Tests', () {
    test('Success returns data correctly', () {
      const result = Result.success('nutrisnap_data');
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 'nutrisnap_data');
      expect(result.errorOrNull, isNull);

      final val = result.when(
        success: (d) => 'got: $d',
        failure: (m, e) => 'fail',
      );
      expect(val, 'got: nutrisnap_data');
    });

    test('Failure returns error message and exception', () {
      final exception = Exception('network err');
      final result = Result<int>.failure('Failed to load', exception);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, 'Failed to load');

      final val = result.when(
        success: (d) => 'ok',
        failure: (m, e) => 'error: $m, ex: $e',
      );
      expect(val, contains('Failed to load'));
    });

    test('Success equality works', () {
      final s1 = Result.success(42);
      final s2 = Result.success(42);
      final s3 = Result.success(99);

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
    });

    test('Failure equality works', () {
      final f1 = Result<int>.failure('err');
      final f2 = Result<int>.failure('err');
      final f3 = Result<int>.failure('other');

      expect(f1, equals(f2));
      expect(f1, isNot(equals(f3)));
    });
  });
}
