import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('SortedMap', () {
    SortedMap<int, String?> createMap() => SortedMap<int, String>(
          (final String? a, final String? b) {
            if (a == null && b != null) {
              return -1;
            }

            if (a != null && b == null) {
              return 1;
            }

            if (a == null && b == null) {
              return 0;
            }

            return a!.compareTo(b!);
          },
          initial: <int, String>{
            1: 'one',
            2: 'two',
            3: 'three',
          },
        );

    group('update', () {
      test('Should update the value of the specified key', () {
        final SortedMap<int, String?> sortedMap = createMap();

        expect(sortedMap.toList(), <String>['one', 'three', 'two']);

        sortedMap.update(2, (final String? value) => 'new two');
        expect(sortedMap[2], 'new two');
        expect(sortedMap.toList(), <String>['new two', 'one', 'three']);
      });

      test('Should add the value if the key does not exist and ifAbsent set', () {
        final SortedMap<int, String?> sortedMap = createMap();

        expect(sortedMap.toList(), <String>['one', 'three', 'two']);

        sortedMap.update(4, (final String? value) => 'four', ifAbsent: () => 'four');
        expect(sortedMap[4], 'four');
        expect(sortedMap.toList(), <String>['four', 'one', 'three', 'two']);
      });
    });
  });
}
