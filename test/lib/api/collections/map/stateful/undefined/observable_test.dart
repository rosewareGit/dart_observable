import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableMapUndefined', () {
    group('length', () {
      test('should return the length of the map', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        expect(rxMap.length.data, 0);

        rxMap.setUndefined();
        expect(rxMap.length.data, null);
        expect(rxMap.length.custom, Undefined());
      });
    });

    group('lengthOrNull', () {
      test('should return the length of the map', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        expect(rxMap.lengthOrNull, 0);

        rxMap.setUndefined();
        expect(rxMap.lengthOrNull, null);
      });
    });

    group('[]', () {
      test('should return the value of the key', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap[1] = 'value';
        expect(rxMap[1], 'value');
        expect(rxMap[2], null);

        rxMap.setUndefined();
        expect(rxMap[1], null);
      });
    });

    group('toList', () {
      test('should return the list of the map', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap[1] = 'value';
        rxMap[2] = 'a';
        expect(rxMap.toList(), <String>['value', 'a']);

        rxMap.setUndefined();
        expect(rxMap.toList(), null);
      });
    });

    group('containsKey', () {
      test('should return true if the key exists', () {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap[1] = 'value';
        expect(rxMap.containsKey(1), true);
        expect(rxMap.containsKey(2), false);

        rxMap.setUndefined();
        expect(rxMap.containsKey(1), false);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the map', () async {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>();
        rxMap[1] = 'value';

        final ObservableMapUndefined<int, String> rxSorted = rxMap.changeFactory(
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

        rxMap.setUndefined();
        expect(rxSorted[1], null);
        expect(rxSorted.value.custom, Undefined());

        await rxMap.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the map', () async {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableMapUndefined<int, String> rxFiltered = rxMap.filterItem(
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

        rxMap.setUndefined();
        expect(rxFiltered[1], null);
        expect(rxFiltered.value.custom, Undefined());
        expect(rxFiltered.toList(), null);

        await rxMap.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the observable of the item', () async {
        final RxMapUndefined<int, String> rxMap = RxMapUndefined<int, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final Observable<StateOf<String?, Undefined>> rxItem = rxMap.rxItem(1);
        rxItem.listen();

        expect(rxItem.value.data, 'value');

        rxMap.remove(1);
        expect(rxItem.value.data, null);

        rxMap[1] = 'newValue';
        expect(rxItem.value.data, 'newValue');

        rxMap.setUndefined();
        expect(rxItem.value.data, null);
        expect(rxItem.value.custom, Undefined());

        await rxMap.dispose();
        expect(rxItem.disposed, true);
      });
    });
  });
}
