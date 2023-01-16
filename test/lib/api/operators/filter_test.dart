import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('filter', () {
    test('Should filter initial value', () {
      final Rx<int> rx = Rx<int>(0, distinct: false);
      final Observable<int?> filtered = rx.filter(
        (final Observable<int> source) => source.value % 3 == 1,
      );

      expect(filtered.value, null);
    });

    test('Should filter items', () async {
      final Rx<int> rx = Rx<int>(0, distinct: false);

      final Observable<int?> filtered = rx.filter(
        (final Observable<int> source) => source.value % 3 == 1,
      );

      int baseCount = 0;
      int filteredCount = 0;

      rx.listen(
        onChange: (final Observable<int> source) {
          ++baseCount;
        },
      );

      filtered.listen(
        onChange: (final Observable<int?> source) {
          ++filteredCount;
        },
      );

      expect(filtered.value, null);
      rx.value = 1;
      expect(filtered.value, 1);
      rx.value = 2;
      expect(filtered.value, 1);
      rx.value = 3;
      expect(filtered.value, 1);
      rx.value = 4;
      expect(filtered.value, 4);
      rx.value = 5;
      expect(filtered.value, 4);

      expect(baseCount, 5);
      expect(filteredCount, 2);

      expect(filtered.disposed, false);

      await rx.dispose();

      expect(rx.disposed, true);
      expect(filtered.disposed, true);
    });
  });
}
