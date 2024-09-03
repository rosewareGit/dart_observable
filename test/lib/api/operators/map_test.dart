import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('map', () {
    test('Should return mapped value', () async {
      final Rx<int> rx = Rx<int>(0);
      final Observable<int> mapped = rx.map<int>((final int value) {
        return value * 2;
      });

      mapped.listen();

      rx.value = 1;
      expect(mapped.value, 2);
      rx.value = 2;
      expect(mapped.value, 4);
      rx.value = 3;
      expect(mapped.value, 6);

      expect(mapped.disposed, false);

      await rx.dispose();

      expect(rx.disposed, true);
      expect(mapped.disposed, true);
    });
  });
}
