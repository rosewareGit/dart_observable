import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableMapFailure', () {
    group('factory', () {
      test('Should create ObservableMapFailure with failure', () {
        final ObservableMapFailure<int, String, String> rxMapFailure =
            RxMapFailure<int, String, String>.failure(failure: 'failure');
        expect(rxMapFailure.value.custom, 'failure');
      });

      test('Should create ObservableMapFailure with initial data', () {
        final ObservableMapFailure<int, String, String> rxMapFailure =
            RxMapFailure<int, String, String>(initial: <int, String>{1: 'value'});
        expect(rxMapFailure[1], 'value');
      });
    });

    group('length', () {
      test('should return the length of the map', () {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>();
        expect(rxMap.length.data, 0);

        rxMap.failure = 'failure';
        expect(rxMap.length.data, null);
        expect(rxMap.length.custom, 'failure');
      });
    });

    group('lengthOrNull', () {
      test('should return the length of the map', () {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>();
        expect(rxMap.lengthOrNull, 0);

        rxMap.failure = 'failure';
        expect(rxMap.lengthOrNull, null);
      });
    });

    group('[]', () {
      test('should return the value of the key', () {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap[1], 'value');
        expect(rxMap[2], null);

        rxMap.failure = 'failure';
        expect(rxMap[1], null);
      });
    });

    group('toList', () {
      test('should return the list of the map', () {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>();
        rxMap[1] = 'value';
        rxMap[2] = 'a';
        expect(rxMap.toList(), <String>['value', 'a']);

        rxMap.failure = 'failure';
        expect(rxMap.toList(), null);
      });
    });

    group('containsKey', () {
      test('should return true if the key exists', () {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap.containsKey(1), true);
        expect(rxMap.containsKey(2), false);

        rxMap.failure = 'failure';
        expect(rxMap.containsKey(1), false);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the map', () async {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>();
        rxMap[1] = 'value';

        final ObservableMapFailure<int, String, String> rxSorted = rxMap.changeFactory(
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

        rxMap.failure = 'failure';
        expect(rxSorted[1], null);
        expect(rxSorted.value.custom, 'failure');

        await rxMap.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the map', () async {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableMapFailure<int, String, String> rxFiltered = rxMap.filterItem(
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

        rxMap.failure = 'failure';
        expect(rxFiltered[1], null);
        expect(rxFiltered.value.custom, 'failure');
        expect(rxFiltered.toList(), null);

        await rxMap.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the observable of the item', () async {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final Observable<StateOf<String?, String>> rxItem = rxMap.rxItem(1);
        rxItem.listen();

        expect(rxItem.value.data, 'value');

        rxMap.remove(1);
        expect(rxItem.value.data, null);

        rxMap[1] = 'newValue';
        expect(rxItem.value.data, 'newValue');

        rxMap.failure = 'failure';
        expect(rxItem.value.data, null);
        expect(rxItem.value.custom, 'failure');

        await rxMap.dispose();
        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map initial failure', () {
        final ObservableMapFailure<int, String, String> rxMap =
            RxMapFailure<int, String, String>.failure(failure: 'failure');
        final ObservableMapFailure<int, String, String> rxMapped = rxMap.mapItem(
          (final int key, final String value) => value.toUpperCase(),
        );

        rxMapped.listen();
        expect(rxMapped[1], null);
        expect(rxMapped.value.custom, 'failure');
      });

      test('should map the items of the map', () async {
        final RxMapFailure<int, String, String> rxMap = RxMapFailure<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableMapFailure<int, String, String> rxMapped = rxMap.mapItem(
          (final int key, final String value) => value.toUpperCase(),
        );

        rxMapped.listen();
        expect(rxMapped[1], 'VALUE');
        expect(rxMapped[2], 'A');
        expect(rxMapped[3], 'B');

        rxMap[4] = 'ab';
        expect(rxMapped[4], 'AB');

        rxMap[2] = 'c';
        expect(rxMapped[2], 'C');

        rxMap[3] = 'aBaaC';
        expect(rxMapped[3], 'ABAAC');

        rxMap.remove(3);
        expect(rxMapped[3], null);

        rxMap.failure = 'failure';
        expect(rxMapped[1], null);
        expect(rxMapped.value.custom, 'failure');
        expect(rxMapped.toList(), null);

        await rxMap.dispose();
        expect(rxMapped.disposed, true);
      });
    });
  });
}
