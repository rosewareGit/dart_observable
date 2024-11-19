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

            return b!.compareTo(a!);
          },
          initial: <int, String>{
            1: 'A',
            2: 'B',
            3: 'C',
          },
        );

    group('entries', () {
      test('Should return the sorted entries of the map', () {
        final SortedMap<int, String?> sortedMap = createMap();

        final List<MapEntry<int, String?>> entries = sortedMap.entries.toList();
        expect(entries[0].key, 3);
        expect(entries[0].value, 'C');

        expect(entries[1].key, 2);
        expect(entries[1].value, 'B');

        expect(entries[2].key, 1);
        expect(entries[2].value, 'A');
      });
    });

    group('update', () {
      test('Should update the value of the specified key', () {
        final SortedMap<int, String?> sortedMap = createMap();

        expect(sortedMap.toList(), <String>['C', 'B', 'A']);

        sortedMap.update(2, (final String? value) => 'Z');
        expect(sortedMap[2], 'Z');
        expect(sortedMap.toList(), <String>['Z', 'C', 'A']);
      });

      test('Should add the value if the key does not exist and ifAbsent set', () {
        final SortedMap<int, String?> sortedMap = createMap();

        expect(sortedMap.toList(), <String>['C', 'B', 'A']);

        sortedMap.update(4, (final String? value) => 'D', ifAbsent: () => 'D');
        expect(sortedMap[4], 'D');
        expect(sortedMap.toList(), <String>['D', 'C', 'B', 'A']);
      });
    });

    group('add', () {
      test('Should add the value to the map', () {
        final SortedMap<int, String?> sortedMap = createMap();

        expect(sortedMap.toList(), <String>['C', 'B', 'A']);

        sortedMap.add(4, 'D');
        expect(sortedMap[4], 'D');
        expect(sortedMap.toList(), <String>['D', 'C', 'B', 'A']);

        sortedMap.add(5, 'D');
        expect(sortedMap[5], 'D');
        expect(sortedMap.toList(), <String>['D', 'D', 'C', 'B', 'A']);

        sortedMap[4] = 'E';
        expect(sortedMap[4], 'E');
        expect(sortedMap.toList(), <String>['E', 'D', 'C', 'B', 'A']);
      });
    });
  });
}
