import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableMapUndefinedFailure', () {
    group('length', () {
      test('should return the length of the map', () {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>();
        expect(rxMap.length.data, null);

        rxMap[1] = 'value';
        expect(rxMap.length.data, 1);

        rxMap.failure = 'failure';
        expect(rxMap.length.data, null);
        expect(rxMap.length.custom, UndefinedFailure<String>.failure('failure'));
      });
    });

    group('lengthOrNull', () {
      test('should return the length of the map', () {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>();
        expect(rxMap.lengthOrNull, null);

        rxMap[1] = 'value';
        expect(rxMap.lengthOrNull, 1);

        rxMap.failure = 'failure';
        expect(rxMap.lengthOrNull, null);
      });
    });

    group('[]', () {
      test('should return the value of the key', () {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap[1], 'value');
        expect(rxMap[2], null);

        rxMap.failure = 'failure';
        expect(rxMap[1], null);
      });
    });

    group('toList', () {
      test('should return the list of the map', () {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>();
        rxMap[1] = 'value';
        rxMap[2] = 'a';
        expect(rxMap.toList(), <String>['value', 'a']);

        rxMap.failure = 'failure';
        expect(rxMap.toList(), null);
      });
    });

    group('containsKey', () {
      test('should return true if the key exists', () {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>();
        rxMap[1] = 'value';
        expect(rxMap.containsKey(1), true);
        expect(rxMap.containsKey(2), false);

        rxMap.failure = 'failure';
        expect(rxMap.containsKey(1), false);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the map', () async {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>();
        rxMap[1] = 'value';

        final ObservableMapUndefinedFailure<int, String, String> rxSorted = rxMap.changeFactory(
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
        expect(rxSorted.value.custom, UndefinedFailure<String>.failure('failure'));

        await rxMap.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the map', () async {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableMapUndefinedFailure<int, String, String> rxFiltered = rxMap.filterItem(
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
        expect(rxFiltered.value.custom, UndefinedFailure<String>.failure('failure'));
        expect(rxFiltered.toList(), null);

        await rxMap.dispose();
        expect(rxFiltered.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the observable of the item', () async {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final Observable<StateOf<String?, UndefinedFailure<String>>> rxItem = rxMap.rxItem(1);
        rxItem.listen();

        expect(rxItem.value.data, 'value');

        rxMap.remove(1);
        expect(rxItem.value.data, null);

        rxMap[1] = 'newValue';
        expect(rxItem.value.data, 'newValue');

        rxMap.failure = 'failure';
        expect(rxItem.value.data, null);
        expect(rxItem.value.custom, UndefinedFailure<String>.failure('failure'));

        await rxMap.dispose();
        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('should return the observable of the item', () async {
        final RxMapUndefinedFailure<int, String, String> rxMap = RxMapUndefinedFailure<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableMapUndefinedFailure<int, String, String> rxMapped = rxMap.mapItem(
          (final int key, final String value) => value.toUpperCase(),
        );

        rxMapped.listen();

        expect(rxMapped[1], 'VALUE');
        expect(rxMapped[2], 'A');
        expect(rxMapped[3], 'B');

        rxMap.failure = 'failure';
        expect(rxMapped[1], null);
        expect(rxMapped.value.custom, UndefinedFailure<String>.failure('failure'));

        await rxMap.dispose();
        expect(rxMapped.disposed, true);
      });
    });
  });
}
