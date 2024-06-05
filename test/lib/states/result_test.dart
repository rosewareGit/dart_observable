import 'package:dart_observable/dart_observable.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('result', () {
    test('getOrDefault', () {
      final Result<int?, int?> result = Result<int?, int?>.success(null);
      expect(result.getOrDefault(1), null);

      final Result<int?, int?> result2 = Result<int?, int?>.failure(null);
      expect(result2.getOrDefault(2), 2);
    });

    test('getOrElse', () {
      final Result<int?, int?> result = Result<int?, int?>.success(null);
      expect(result.getOrElse(onFailure: (final int? fail) => 1), null);

      final Result<int?, int?> result2 = Result<int?, int?>.failure(null);
      expect(result2.getOrElse(onFailure: (final int? fail) => 1), 1);
    });
  });
}
