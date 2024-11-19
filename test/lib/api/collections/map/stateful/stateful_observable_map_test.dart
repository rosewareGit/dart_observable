import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableStatefulMap', () {
    group('just', () {
      test('should create an ObservableStatefulMap with the initial value', () {
        final ObservableStatefulMap<int, String, String> rxMap = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'value'},
        );
        expect(rxMap[1], 'value');
      });

      test('should create an ObservableStatefulMap with the factory', () {
        final ObservableStatefulMap<int, String, String> rxMap = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'v', 2: 'a', 3: 'b'},
          factory: (final Map<int, String>? map) => SortedMap<int, String>(
            (final String left, final String right) => left.compareTo(right),
            initial: map,
          ),
        );
        expect(rxMap[1], 'v');
        expect(rxMap[2], 'a');
        expect(rxMap[3], 'b');

        expect(rxMap.toList(), <String>['a', 'b', 'v']);
      });
    });

    group('custom', () {
      test('should create an ObservableStatefulMap with the custom state', () {
        final ObservableStatefulMap<int, String, String> rxMap = ObservableStatefulMap<int, String, String>.custom(
          'custom',
        );
        expect(rxMap.value.rightOrNull, 'custom');
      });
    });

    group('merged', () {
      test('should merge two ObservableStatefulMaps', () {
        final ObservableStatefulMap<int, String, String> map1 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'value1', 2: 'value2'},
        );
        final ObservableStatefulMap<int, String, String> map2 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{3: 'value3', 4: 'value4'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
        );

        mergedMap.listen();

        expect(mergedMap[1], 'value1');
        expect(mergedMap[2], 'value2');
        expect(mergedMap[3], 'value3');
        expect(mergedMap[4], 'value4');
      });

      test('should handle overlapping keys by using the second map\'s values', () {
        final ObservableStatefulMap<int, String, String> map1 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'value1', 2: 'value2'},
        );
        final ObservableStatefulMap<int, String, String> map2 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{2: 'newValue2', 3: 'value3'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
        );

        mergedMap.listen();

        expect(mergedMap[1], 'value1');
        expect(mergedMap[2], 'newValue2');
        expect(mergedMap[3], 'value3');
      });

      test('should handle empty maps', () {
        final ObservableStatefulMap<int, String, String> map1 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{},
        );
        final ObservableStatefulMap<int, String, String> map2 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
        );

        mergedMap.listen();

        expect(mergedMap.length, 0);
      });

      test('should handle one empty map and one non-empty map', () {
        final ObservableStatefulMap<int, String, String> map1 =
            ObservableStatefulMap<int, String, String>.just(<int, String>{});
        final ObservableStatefulMap<int, String, String> map2 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'value1'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
        );

        mergedMap.listen();

        expect(mergedMap[1], 'value1');
      });

      test('should handle maps with overlapping keys and different values', () {
        final ObservableStatefulMap<int, String, String> map1 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'value1', 2: 'value2'},
        );
        final ObservableStatefulMap<int, String, String> map2 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'newValue1', 3: 'value3'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
        );

        mergedMap.listen();

        expect(mergedMap[1], 'newValue1');
        expect(mergedMap[2], 'value2');
        expect(mergedMap[3], 'value3');
      });

      test('should handle maps with overlapping keys and different values with a conflict resolver', () {
        final ObservableStatefulMap<int, String, String> map1 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'value1', 2: 'value2'},
        );
        final ObservableStatefulMap<int, String, String> map2 = ObservableStatefulMap<int, String, String>.just(
          <int, String>{1: 'newValue1', 3: 'value3'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
          conflictResolver: (final int key, final String current, final ObservableItemChange<String?> conflict) {
            return conflict.newValue;
          },
        );

        mergedMap.listen();

        expect(mergedMap[1], 'newValue1');
        expect(mergedMap[2], 'value2');
        expect(mergedMap[3], 'value3');
      });

      test('Should handle custom state with state resolver', () {
        final RxStatefulMap<int, String, String> map1 = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'value1', 2: 'value2'},
        );
        final RxStatefulMap<int, String, String> map2 = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'newValue1', 3: 'value3'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
          stateResolver: (final String state, final Iterable<ObservableStatefulMap<int, String, String>> collections) {
            expect(state, 'custom');
            return Either<Map<int, String>, String>.right('customState');
          },
        );

        mergedMap.listen();

        map1.setState('custom');

        expect(mergedMap.value.rightOrNull, 'customState');
      });

      test('Should remove items from source when transitioned to custom without a state resolver', () {
        final RxStatefulMap<int, String, String> map1 = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'value1', 2: 'value2'},
        );
        final RxStatefulMap<int, String, String> map2 = RxStatefulMap<int, String, String>(
          initial: <int, String>{1: 'newValue1', 3: 'value3'},
        );

        final ObservableStatefulMap<int, String, String> mergedMap = ObservableStatefulMap<int, String, String>.merged(
          collections: <ObservableStatefulMap<int, String, String>>[map1, map2],
        );

        mergedMap.listen();

        map1.setState('custom');

        expect(mergedMap.value.leftOrNull!.mapView, <int, String>{1: 'newValue1', 3: 'value3'});
        expect(mergedMap.value.rightOrNull, null);
      });
    });

    group('fromStream', () {
      test('should create an ObservableStatefulMap from a stream', () {
        final StreamController<Either<ObservableMapUpdateAction<int, String>, String>> controller =
            StreamController<Either<ObservableMapUpdateAction<int, String>, String>>(sync: true);

        final ObservableStatefulMap<int, String, String> rxMap =
            ObservableStatefulMap<int, String, String>.fromStream(stream: controller.stream);

        rxMap.listen();

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(addItems: <int, String>{1: 'value'}),
          ),
        );

        expect(rxMap[1], 'value');

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(addItems: <int, String>{2: 'anotherValue'}),
          ),
        );
        expect(rxMap[2], 'anotherValue');

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(removeKeys: <int>{1}),
          ),
        );
        expect(rxMap[1], null);
        expect(rxMap[2], 'anotherValue');

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(addItems: <int, String>{2: 'updatedValue'}),
          ),
        );
        expect(rxMap[2], 'updatedValue');

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.right('custom'),
        );
        expect(rxMap.value.rightOrNull, 'custom');
      });

      test('should handle stream errors', () async {
        final StreamController<Either<ObservableMapUpdateAction<int, String>, String>> controller =
            StreamController<Either<ObservableMapUpdateAction<int, String>, String>>(sync: true);

        final ObservableStatefulMap<int, String, String> rxMap = ObservableStatefulMap<int, String, String>.fromStream(
          stream: controller.stream,
          onError: (final dynamic error) {
            return Either<Map<int, String>, String>.right('error');
          },
        );

        rxMap.listen();

        controller.addError(Exception('Stream error'));

        expect(rxMap.value.rightOrNull, 'error');
      });

      test('should handle stream completion', () async {
        final StreamController<Either<ObservableMapUpdateAction<int, String>, String>> controller =
            StreamController<Either<ObservableMapUpdateAction<int, String>, String>>(sync: true);

        final ObservableStatefulMap<int, String, String> rxMap =
            ObservableStatefulMap<int, String, String>.fromStream(stream: controller.stream);

        rxMap.listen();

        await controller.close();

        expect(rxMap.disposed, true);
      });

      test('Should update the map with all the pending changes after listening', () async {
        final StreamController<Either<ObservableMapUpdateAction<int, String>, String>> controller =
            StreamController<Either<ObservableMapUpdateAction<int, String>, String>>(sync: true);

        final ObservableStatefulMap<int, String, String> rxMap =
            ObservableStatefulMap<int, String, String>.fromStream(stream: controller.stream);

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(addItems: <int, String>{1: 'value'}),
          ),
        );

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(addItems: <int, String>{2: 'anotherValue'}),
          ),
        );

        Disposable listener = rxMap.listen();

        expect(rxMap[1], 'value');
        expect(rxMap[2], 'anotherValue');

        listener.dispose();

        controller.add(
          Either<ObservableMapUpdateAction<int, String>, String>.left(
            ObservableMapUpdateAction<int, String>(addItems: <int, String>{3: 'newValue'}),
          ),
        );

        listener = rxMap.listen();

        expect(rxMap[3], 'newValue');
      });
    });

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

      test('Should respect factory when set', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxFiltered = rxMap.filterItem(
          (final int key, final String value) => value.contains('a'),
          factory: (final Map<int, String>? map) => SortedMap<int, String>(
            (final String left, final String right) => left.compareTo(right),
            initial: map,
          ),
        );

        rxFiltered.listen();

        expect(rxFiltered.toList(), <String>['a', 'value']);

        rxMap.setState('custom');
        expect(rxFiltered[1], null);
        expect(rxFiltered.value.rightOrNull, 'custom');
        expect(rxFiltered.toList(), null);

        rxMap[4] = 'c';
        expect(rxFiltered[4], null);
        expect(rxFiltered.toList(), <String>[]);

        rxMap[5] = 'a';
        expect(rxFiltered[5], 'a');
        expect(rxFiltered.toList(), <String>['a']);

        rxMap[4] = 'ca';
        expect(rxFiltered[4], 'ca');
        expect(rxFiltered.toList(), <String>['a', 'ca']);

        rxMap.remove(4);
        expect(rxFiltered[4], null);
        expect(rxFiltered.toList(), <String>['a']);
      });
    });

    group('filterItemWithState', () {
      test('should filter the items of the map with state', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxFiltered = rxMap.filterItemWithState(
          (final Either<MapEntry<int, String>, String> item) => item.fold(
            onLeft: (final MapEntry<int, String> entry) => entry.value.contains('a'),
            onRight: (final String state) => state.contains('custom'),
          ),
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

        rxMap.setState('test');
        expect(
          rxFiltered.value.rightOrNull,
          'custom',
          reason: 'Should not update the state if the predicate returns false',
        );
        expect(rxFiltered.toList(), null);

        await rxMap.dispose();
        expect(rxFiltered.disposed, true);
      });

      test('Should respect factory when set', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxFiltered = rxMap.filterItemWithState(
          (final Either<MapEntry<int, String>, String> item) => item.fold(
            onLeft: (final MapEntry<int, String> entry) => entry.value.contains('a'),
            onRight: (final String state) => state.contains('custom'),
          ),
          factory: (final Map<int, String>? map) => SortedMap<int, String>(
            (final String left, final String right) => left.compareTo(right),
            initial: map,
          ),
        );

        rxFiltered.listen();

        expect(rxFiltered.toList(), <String>['a', 'value']);

        rxMap.setState('custom');
        expect(rxFiltered[1], null);
        expect(rxFiltered.value.rightOrNull, 'custom');
        expect(rxFiltered.toList(), null);

        rxMap.setState('test');
        expect(
          rxFiltered.value.rightOrNull,
          'custom',
          reason: 'Should not update the state if the predicate returns false',
        );

        rxMap[4] = 'c';
        expect(rxFiltered[4], null);
        expect(rxFiltered.toList(), <String>[]);

        rxMap[5] = 'a';
        expect(rxFiltered[5], 'a');
        expect(rxFiltered.toList(), <String>['a']);

        rxMap[4] = 'ca';
        expect(rxFiltered[4], 'ca');
        expect(rxFiltered.toList(), <String>['a', 'ca']);

        rxMap.remove(4);
        expect(rxFiltered[4], null);
        expect(rxFiltered.toList(), <String>['a']);

        rxMap.setState('test');
        expect(rxFiltered[1], null);
        expect(rxFiltered.toList(), <String>['a']);

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
      test('Should map items', () async {
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

      test('Should respect factory when set', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxMapped = rxMap.mapItem(
          (final int key, final String value) => value.toUpperCase(),
          factory: (final Map<int, String>? map) => SortedMap<int, String>(
            (final String left, final String right) => left.compareTo(right),
            initial: map,
          ),
        );

        rxMapped.listen();

        expect(rxMapped.toList(), <String>['A', 'B', 'VALUE']);

        rxMap.setState('custom');
        expect(rxMapped[1], null);
        expect(rxMapped.value.rightOrNull, 'custom');
        expect(rxMapped.toList(), null);

        rxMap[4] = 'c';
        expect(rxMapped[4], 'C');
        expect(rxMapped.toList(), <String>['C']);

        rxMap.remove(4);
        expect(rxMapped[4], null);
        expect(rxMapped.toList(), <String>[]);
      });
    });

    group('sorted', (){
      test('Should sort the items by the value', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxSorted = rxMap.sorted((final String left, final String right) => left.compareTo(right));
        rxSorted.listen();

        expect(rxSorted.toList(), <String>['a', 'b', 'value']);

        rxMap.setState('custom');
        expect(rxSorted[1], null);
        expect(rxSorted.value.rightOrNull, 'custom');
        expect(rxSorted.toList(), null);

        rxMap[4] = 'c';
        expect(rxSorted[4], 'c');
        expect(rxSorted.toList(), <String>['c']);

        rxMap.remove(4);
        expect(rxSorted[4], null);
        expect(rxSorted.toList(), <String>[]);

        rxMap[5] = 'd';
        expect(rxSorted[5], 'd');
        expect(rxSorted.toList(), <String>['d']);

        rxMap[4] = 'c';
        expect(rxSorted[4], 'c');
        expect(rxSorted.toList(), <String>['c', 'd']);

        rxMap.remove(4);
        expect(rxSorted[4], null);
        expect(rxSorted.toList(), <String>['d']);

        rxMap.setState('custom');
        expect(rxSorted[1], null);
        expect(rxSorted.toList(), null);

        await rxMap.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('mapItemWithState', () {
      test('Should map change', () async {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxMapped = rxMap.mapItemWithState(
          valueMapper: (final int key, final String value) => value.toUpperCase(),
          stateMapper: (final String state) => state.toLowerCase(),
        );

        rxMapped.listen();

        expect(rxMapped[1], 'VALUE');
        expect(rxMapped[2], 'A');
        expect(rxMapped[3], 'B');

        rxMap[1] = 'newValue';
        expect(rxMapped[1], 'NEWVALUE');

        rxMap.remove(2);
        expect(rxMapped[2], null);

        rxMap.setState('CUSTOM');
        expect(rxMapped[1], null);
        expect(rxMapped.value.rightOrNull, 'custom');

        await rxMap.dispose();
        expect(rxMapped.disposed, true);
      });

      test('Should respect factory when set', () {
        final RxStatefulMap<int, String, String> rxMap = RxStatefulMap<int, String, String>(
          initial: <int, String>{
            1: 'value',
            2: 'a',
            3: 'b',
          },
        );

        final ObservableStatefulMap<int, String, String> rxMapped = rxMap.mapItemWithState(
          valueMapper: (final int key, final String value) => value.toUpperCase(),
          stateMapper: (final String state) => state.toLowerCase(),
          factory: (final Map<int, String>? map) => SortedMap<int, String>(
            (final String left, final String right) => left.compareTo(right),
            initial: map,
          ),
        );

        rxMapped.listen();

        expect(rxMapped.toList(), <String>['A', 'B', 'VALUE']);

        rxMap.setState('custom');
        expect(rxMapped[1], null);
        expect(rxMapped.value.rightOrNull, 'custom');
        expect(rxMapped.toList(), null);

        rxMap[4] = 'c';
        expect(rxMapped[4], 'C');
        expect(rxMapped.toList(), <String>['C']);

        rxMap.remove(4);
        expect(rxMapped[4], null);
        expect(rxMapped.toList(), <String>[]);
      });
    });
  });
}
