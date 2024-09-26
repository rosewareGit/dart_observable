import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('switchMap', () {
    test('Should listen on initial value', () {
      final Rx<int> rx = Rx<int>(0);

      final Rx<String> producerEven = Rx<String>('0');
      final Rx<String> producerOdd = Rx<String>('1');

      final Observable<String> mapped = rx.switchMap<String>(
        (final int value) {
          if (value.isEven) {
            return producerEven;
          }
          return producerOdd;
        },
      );

      mapped.listen();
      producerEven.value = '11';

      expect(mapped.value, '11');
    });

    test('Should return mapped value', () async {
      final Rx<int> rx = Rx<int>(0);

      final Rx<String> producerEven = Rx<String>('0');
      final Rx<String> producerOdd = Rx<String>('1');

      final Observable<String> mapped = rx.switchMap<String>(
        (final int value) {
          if (value.isEven) {
            return producerEven;
          }
          return producerOdd;
        },
      );

      mapped.listen();

      rx.value = 1;
      expect(mapped.value, '1');
      rx.value = 2;
      expect(mapped.value, '0');

      producerEven.value = '11';
      producerOdd.value = '8';

      expect(mapped.value, '11');

      rx.value = 3;
      expect(mapped.value, '8');
    });

    test('Should dispose when source disposed', () async {
      final Rx<int> rx = Rx<int>(0);

      final Rx<String> producerEven = Rx<String>('0');
      final Rx<String> producerOdd = Rx<String>('1');

      final Observable<String> mapped = rx.switchMap<String>(
        (final int value) {
          if (value.isEven) {
            return producerEven;
          }
          return producerOdd;
        },
      );

      mapped.listen();

      await rx.dispose();

      expect(mapped.disposed, true);
    });

    test('Should dispose when no listeners', () {
      final Rx<int> rx = Rx<int>(0);

      final Rx<String> producerEven = Rx<String>('0');
      final Rx<String> producerOdd = Rx<String>('1');

      final Observable<String> mapped = rx.switchMap<String>(
        (final int value) {
          if (value.isEven) {
            return producerEven;
          }
          return producerOdd;
        },
      );

      mapped.listen();

      mapped.dispose();

      expect(mapped.disposed, true);
    });
  });
}
