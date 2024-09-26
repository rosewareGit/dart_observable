import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableStatefulMap', () {
    group('length', () {
      test('should return the length of the map', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        expect(rxMap.length, 0);

        rxMap[1] = 'value';
        expect(rxMap.length, 1);

        rxMap.setState('custom');
        expect(rxMap.length, null);
      });
    });

    group('[]', () {
      test('should return the value of the key', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap[1], 'value');
        expect(rxMap[2], null);

        rxMap.setState('custom');
        expect(rxMap[1], null);
      });
    });

    group('toList', () {
      test('should return the list of the map', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap[1] = 'value';
        rxMap[2] = 'a';
        expect(rxMap.toList(), <String>['value', 'a']);

        rxMap.setState('custom');
        expect(rxMap.toList(), null);
      });
    });

    group('containsKey', () {
      test('should return true if the key exists', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap.containsKey(1), true);
        expect(rxMap.containsKey(2), false);

        rxMap.setState('custom');
        expect(rxMap.containsKey(1), false);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the map', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>();
        rxMap[1] = 'value';

        final ObservableStatefulMap<int, String, String> rxSorted = rxMap.changeFactory(
          (final Map<int, String>? map) => SortedMap<int, String>(
            (final String left, final String right) => left.compareTo(right),
            initial: map,
          ),
        );
        rxSorted.listen();

        expect(rxSorted[1], 'value');

        rxMap[2] = 'a';
        expect(rxSorted[2], 'a');

        expect(rxSorted.toList(), <String>['a', 'value']);

        rxMap.remove(2);
        expect(rxSorted[2], null);
        expect(rxSorted.toList(), <String>['value']);

        rxMap.setState('custom');
        expect(rxSorted[1], null);
        expect(rxSorted.value.rightOrNull, 'custom');

        await rxMap.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the map', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxFiltered = rxMap.filterItem(
          (final int key, final String value) => value.contains('a'),
        );

        rxFiltered.listen();
        expect(rxFiltered[1], 'value');
        expect(rxFiltered[2], 'a');
        expect(rxFiltered[3], null);

        rxMap[4] = 'ab';
        expect(rxFiltered[4], 'ab');

        rxMap[2] = 'c';
        expect(rxFiltered[2], null);

        rxMap[3] = 'aBaaC';
        expect(rxFiltered[3], 'aBaaC');

        rxMap.setState('custom');
        expect(rxFiltered[1], null);
        expect(rxFiltered.value.rightOrNull, 'custom');
        expect(rxFiltered.toList(), null);

        await rxMap.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the observable of the item', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final Observable<Either<String?, String>> rxItem = rxMap.rxItem(1);
        rxItem.listen();

        expect(rxItem.value.leftOrNull, 'value');

        rxMap.remove(1);
        expect(rxItem.value.leftOrNull, null);

        rxMap[1] = 'newValue';
        expect(rxItem.value.leftOrNull, 'newValue');

        rxMap.setState('custom');
        expect(rxItem.value.leftOrNull, null);
        expect(rxItem.value.rightOrNull, 'custom');

        await rxMap.dispose();
        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('should return the observable of the item', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxMapped = rxMap.mapItem(
          (final int key, final String value) => value.toUpperCase(),
        );

        rxMapped.listen();

        expect(rxMapped[1], 'VALUE');
        expect(rxMapped[2], 'A');
        expect(rxMapped[3], 'B');

        rxMap.setState('custom');
        expect(rxMapped[1], null);
        expect(rxMapped.value.rightOrNull, 'custom');

        await rxMap.dispose();
        expect(rxMapped.disposed, true);
      });
    });
  });
}
