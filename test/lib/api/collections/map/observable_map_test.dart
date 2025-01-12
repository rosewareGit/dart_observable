import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

class TestModel {
  final int value;

  TestModel(this.value);
}

void main() {
  group('ObservableMap', () {
    group('just', () {
      test('Should create an observable with an empty map', () {
        final ObservableMap<String, int> rxMap = ObservableMap<String, int>.just(<String, int>{});

        rxMap.listen();

        expect(rxMap.length, 0);
      });

      test('Should create an observable', () {
        final ObservableMap<String, int> rxMap = ObservableMap<String, int>.just(
          <String, int>{
            'a': 1,
            'b': 2,
          },
        );

        rxMap.listen();

        expect(rxMap.length, 2);
        expect(rxMap['a'], 1);
        expect(rxMap['b'], 2);
      });
    });

    group('merged', () {
      test('Should merge maps with different keys', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'c': 3,
          'd': 4,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
        );

        merged.listen();

        expect(merged.length, 4);
        expect(merged['a'], 1);
        expect(merged['b'], 2);
        expect(merged['c'], 3);
        expect(merged['d'], 4);
      });

      test('Should handle identical keys and values', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
        );

        merged.listen();

        expect(merged.length, 2);
        expect(merged['a'], 1);
        expect(merged['b'], 2);
      });

      test('Should handle updates in source maps', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{'a': 1});
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{'b': 2});

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
        );

        Map<String, int>? lastState;
        merged.listen(
          onChange: (final Map<String, int> state) {
            lastState = state;
          },
        );

        expect(merged.length, 2);
        expect(merged.value, <String, int>{'a': 1, 'b': 2});
        expect(lastState, <String, int>{'a': 1, 'b': 2});

        rxMap1['a'] = 3;
        expect(merged.value, <String, int>{'a': 3, 'b': 2});
        expect(lastState, <String, int>{'a': 3, 'b': 2});

        rxMap2['b'] = 4;
        expect(merged.value, <String, int>{'a': 3, 'b': 4});
        expect(lastState, <String, int>{'a': 3, 'b': 4});

        rxMap1['c'] = 5;
        expect(merged.value, <String, int>{'a': 3, 'b': 4, 'c': 5});
        expect(lastState, <String, int>{'a': 3, 'b': 4, 'c': 5});

        rxMap1.value = <String, int>{'a': 1, 'c': 2};
        expect(merged.value, <String, int>{'a': 1, 'b': 4, 'c': 2});
        expect(lastState, <String, int>{'a': 1, 'b': 4, 'c': 2});

        rxMap1.value = <String, int>{'a': 1, 'c': 2, 'd': 5};
        expect(rxMap2.value, <String, int>{'b': 4});
        expect(merged.value, <String, int>{'a': 1, 'b': 4, 'c': 2, 'd': 5});
        expect(lastState, <String, int>{'a': 1, 'b': 4, 'c': 2, 'd': 5});
      });

      test('Should handle removals in source maps', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'b': 2,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
        );

        merged.listen();

        expect(merged.length, 2);
        expect(merged['a'], 1);
        expect(merged['b'], 2);

        rxMap1.remove('a');
        expect(merged['a'], null);

        rxMap2.remove('b');
        expect(merged['b'], null);
      });

      test('Should handle empty collections', () {
        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[],
        );

        merged.listen();

        expect(merged.length, 0);
      });

      test('Should resolve conflicts with null values', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'a': 3,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
        );

        merged.listen();
        expect(merged['a'], 3);

        rxMap2.remove('a');
        expect(merged['a'], 1);
      });

      test('Should respect factory when merging', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'b': 2,
        });

        final ObservableMap<String, int> rxValueDescendingMergedMap = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
          factory: (final Map<String, int>? items) {
            return SortedMap<String, int>(
              (final int left, final int right) {
                return right.compareTo(left);
              },
              initial: items,
            );
          },
        );

        rxValueDescendingMergedMap.listen();

        expect(rxValueDescendingMergedMap.toList(), <int>[2, 1]);

        rxMap1['a'] = 3;
        rxMap2['b'] = 1;

        expect(rxValueDescendingMergedMap.toList(), <int>[3, 1]);

        rxMap2['c'] = 0;
        expect(rxValueDescendingMergedMap.toList(), <int>[3, 1, 0]);

        rxMap1.remove('a');
        expect(rxValueDescendingMergedMap.toList(), <int>[1, 0]);
      });

      test('Should handle overlapping keys', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'b': 3,
          'c': 4,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2],
        );

        merged.listen();

        expect(merged.length, 3);
        expect(merged['a'], 1);
        expect(merged['b'], 3);
        expect(merged['c'], 4);
      });

      test('Should merge multiple maps', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'c': 3,
          'd': 4,
        });
        final RxMap<String, int> rxMap3 = RxMap<String, int>(<String, int>{
          'e': 5,
          'f': 6,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2, rxMap3],
        );

        merged.listen();

        expect(merged.length, 6);
        expect(merged['a'], 1);
        expect(merged['b'], 2);
        expect(merged['c'], 3);
        expect(merged['d'], 4);
        expect(merged['e'], 5);
        expect(merged['f'], 6);

        rxMap1['a'] = 2;
        rxMap2['c'] = 4;
        rxMap3['e'] = 6;

        expect(merged['a'], 2);
        expect(merged['c'], 4);
        expect(merged['e'], 6);

        rxMap1.remove('a');
        rxMap2.remove('c');
        rxMap3.remove('e');

        expect(merged['a'], null);
        expect(merged['c'], null);
        expect(merged['e'], null);

        rxMap1['e'] = 7;

        expect(merged['e'], 7);
      });

      test('Should update the merged map based on the factory', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'c': 3,
          'd': 4,
        });
        final RxMap<String, int> rxMap3 = RxMap<String, int>(<String, int>{
          'e': 5,
          'f': 6,
        });

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2, rxMap3],
          factory: (final Map<String, int>? items) {
            return SplayTreeMap<String, int>.of(
              items ?? <String, int>{},
              (final String a, final String b) => b.compareTo(a),
            );
          },
        );

        merged.listen();

        expect(merged.length, 6);
        expect(merged['a'], 1);
        expect(merged['b'], 2);
        expect(merged['c'], 3);
        expect(merged['d'], 4);
        expect(merged['e'], 5);
        expect(merged['f'], 6);
        expect(merged.toList(), <int>[6, 5, 4, 3, 2, 1]);

        rxMap1['a'] = 2;
        rxMap2['c'] = 4;
        rxMap3['e'] = 6;

        expect(merged['a'], 2);
        expect(merged['c'], 4);
        expect(merged['e'], 6);

        rxMap1.remove('a');
        rxMap2.remove('c');
        rxMap3.remove('e');
        expect(merged.toList(), <int>[6, 4, 2]);

        expect(merged['a'], null);
        expect(merged['c'], null);
        expect(merged['e'], null);

        rxMap1['e'] = 7;

        expect(merged['e'], 7);
        expect(merged.toList(), <int>[6, 7, 4, 2]);
      });

      test('Should resolve conflicts', () {
        final RxMap<String, int> rxMap1 = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final RxMap<String, int> rxMap2 = RxMap<String, int>(<String, int>{
          'a': 3,
          'c': 4,
        });
        final RxMap<String, int> rxMap3 = RxMap<String, int>();

        final ObservableMap<String, int> merged = ObservableMap<String, int>.merged(
          collections: <ObservableMap<String, int>>[rxMap1, rxMap2, rxMap3],
          conflictResolver: (
            final String key,
            final int current,
            final ObservableItemChange<int?> change,
          ) {
            final int diff = (change.newValue ?? 0) - (change.oldValue ?? 0);
            return current + diff;
          },
        );

        merged.listen();

        expect(merged.length, 3);
        expect(merged['a'], 4);
        expect(merged['b'], 2);
        expect(merged['c'], 4);

        rxMap3['a'] = 5;
        expect(merged['a'], 1 + 3 + 5);

        rxMap1['a'] = 2;
        rxMap2['c'] = 5;

        expect(merged['a'], 2 + 3 + 5);
        expect(merged['c'], 5);

        rxMap1.remove('a');
        rxMap2.remove('c');

        expect(merged['a'], 3 + 5);
        expect(merged['c'], null);

        rxMap1['e'] = 7;
        expect(merged['e'], 7);

        rxMap1['a'] = 1;
        expect(merged['a'], 9);

        rxMap1.remove('a');
        rxMap2.remove('a');
        rxMap3.remove('a');

        expect(merged['a'], null);
      });
    });

    group('sorted', () {
      test('Should sort the map based on the values', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 3,
          'b': 1,
          'c': 2,
        });

        final ObservableMap<String, int> sorted = rxMap.sorted((final int a, final int b) => a.compareTo(b));

        sorted.listen();

        expect(sorted.length, 3);
        expect(sorted.toList(), <int>[1, 2, 3]);

        rxMap['a'] = 1;
        rxMap['b'] = 3;
        rxMap['c'] = 2;

        expect(sorted.toList(), <int>[1, 2, 3]);

        rxMap['d'] = 0;
        expect(sorted.toList(), <int>[0, 1, 2, 3]);

        rxMap.remove('a');
        expect(sorted.toList(), <int>[0, 2, 3]);

        rxMap['d'] = 5;
        expect(sorted.toList(), <int>[2, 3, 5]);

        await rxMap.dispose();
        expect(sorted.disposed, true);
      });
    });

    group('fromStream', () {
      test('Should map data from stream', () async {
        final StreamController<ObservableMapUpdateAction<String, int>> streamController =
            StreamController<ObservableMapUpdateAction<String, int>>.broadcast(sync: true);
        final ObservableMap<String, int> map = ObservableMap<String, int>.fromStream(
          stream: streamController.stream,
        );

        expect(map.length, 0);

        final Disposable listener = map.listen();

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            addItems: <String, int>{
              'a': 1,
              'b': 2,
            },
          ),
        );

        expect(map.length, 2);
        expect(map['a'], 1);
        expect(map['b'], 2);

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            removeKeys: <String>{'a'},
            addItems: <String, int>{'c': 3},
          ),
        );

        expect(map.length, 2);
        expect(map['a'], null);
        expect(map['b'], 2);
        expect(map['c'], 3);

        await listener.dispose();

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            removeKeys: <String>{'b'},
            addItems: <String, int>{'d': 4},
          ),
        );

        expect(map.length, 2);

        map.listen();

        expect(map.length, 2);
        expect(map['a'], null);
        expect(map['b'], null);
        expect(map['c'], 3);
        expect(map['d'], 4);
      });

      test('Should handle stream errors', () {
        final StreamController<ObservableMapUpdateAction<String, int>> streamController =
            StreamController<ObservableMapUpdateAction<String, int>>.broadcast(sync: true);
        final ObservableMap<String, int> map = ObservableMap<String, int>.fromStream(
          stream: streamController.stream,
          onError: (final dynamic error) => <String, int>{'error': -1},
        );

        expect(map.length, 0);

        map.listen();

        streamController.addError(Exception('Test error'));

        expect(map.length, 1);
        expect(map['error'], -1);
      });

      test('Should handle stream completion', () async {
        final StreamController<ObservableMapUpdateAction<String, int>> streamController =
            StreamController<ObservableMapUpdateAction<String, int>>.broadcast(sync: true);
        final ObservableMap<String, int> map = ObservableMap<String, int>.fromStream(
          stream: streamController.stream,
        );

        expect(map.length, 0);

        map.listen();

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            addItems: <String, int>{'a': 1},
          ),
        );

        expect(map.length, 1);
        expect(map['a'], 1);

        await streamController.close();

        expect(map.length, 1);
        expect(map['a'], 1);

        expect(map.disposed, true);
      });

      test('Should update the map with all the pending changes after listening', () async {
        final StreamController<ObservableMapUpdateAction<String, int>> streamController =
            StreamController<ObservableMapUpdateAction<String, int>>.broadcast(sync: true);
        final ObservableMap<String, int> map = ObservableMap<String, int>.fromStream(
          stream: streamController.stream,
        );

        expect(map.length, 0);

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            addItems: <String, int>{
              'a': 1,
              'b': 2,
            },
          ),
        );

        expect(map.length, 0);

        final Disposable listener = map.listen();

        expect(map.length, 2);
        expect(map['a'], 1);
        expect(map['b'], 2);

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            removeKeys: <String>{'a'},
            addItems: <String, int>{'c': 3},
          ),
        );

        expect(map.length, 2);
        expect(map['a'], null);
        expect(map['b'], 2);
        expect(map['c'], 3);

        await listener.dispose();

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            removeKeys: <String>{'b'},
            addItems: <String, int>{'d': 4},
          ),
        );

        expect(map.length, 2);

        map.listen();

        expect(map.length, 2);
        expect(map['a'], null);
        expect(map['b'], null);
        expect(map['c'], 3);
        expect(map['d'], 4);
      });
    });

    group('value', () {
      test('Should return an unmodifiable map', () {
        final ObservableMap<String, int> map = ObservableMap<String, int>.just(<String, int>{
          'a': 1,
          'b': 2,
        });

        final Map<String, int> value = map.value;

        expect(value.length, 2);
        expect(value['a'], 1);
        expect(value['b'], 2);

        expect(() => value['a'] = 3, throwsUnsupportedError);
        expect(() => value['c'] = 3, throwsUnsupportedError);
        expect(() => value.remove('a'), throwsUnsupportedError);
      });
    });

    group('operator []', () {
      test('should return the value for the given key', () {
        final ObservableMap<String, int> map = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        expect(map['a'], 1);
        expect(map['b'], 2);
        expect(map['c'], null);
      });
    });

    group('rxItem', () {
      test('Should map initial state', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        final Observable<int?> b = rxMap.rxItem('b');
        final Observable<int?> c = rxMap.rxItem('c');

        expect(a.value, 1);
        expect(b.value, 2);
        expect(c.value, null);
      });

      test('Should only emit update after listen', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final Observable<int?> a = rxMap.rxItem('a');

        // Observable cold by default
        rxMap['a'] = 3;

        expect(a.value, 1);
        final Disposable listener = a.listen();
        expect(a.value, 3);
        await listener.dispose();

        // Should not be updated now
        rxMap['a'] = 4;
        rxMap['a'] = 5;
        expect(a.value, 3);

        // Should be updated now
        a.listen();
        expect(a.value, 5);
      });

      test('Should update value for key', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        a.listen();

        expect(a.value, 1);

        rxMap['a'] = 3;
        expect(a.value, 3);

        rxMap.remove('a');
        expect(a.value, null);

        rxMap['a'] = 4;
        expect(a.value, 4);
      });

      test('Should dispose when source disposed', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        a.listen();
        expect(a.value, 1);
        await rxMap.dispose();
        expect(a.disposed, true);
      });

      test('Should dispose when listener disposed', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        final Disposable sub = a.listen();
        expect(a.value, 1);
        await sub.dispose();
      });
    });

    group('containsKey', () {
      test('Should return true if key is present', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });

        expect(rxMap.containsKey('a'), true);
        expect(rxMap.containsKey('b'), true);
        expect(rxMap.containsKey('c'), false);
      });
    });

    group('filterMap', () {
      test('Should update state when source change', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        rxMap['a'] = 2;
        rxMap.remove('b');

        final ObservableMap<String, int> filtered = rxMap.filterItem((final String key, final int value) {
          return value > 1;
        });

        expect(filtered.length, 0);
        expect(filtered['a'], null);
        expect(filtered['b'], null);
        expect(filtered['c'], null);

        final Disposable listener = filtered.listen();

        expect(filtered['a'], 2);
        expect(filtered['b'], null);
        expect(filtered['c'], 3);
        expect(filtered.length, 2);

        await listener.dispose();

        // Should not be updated now
        rxMap['a'] = 0;
        rxMap['b'] = 5;
        rxMap['c'] = 0;
        rxMap['d'] = 3;

        expect(filtered['a'], 2);
        expect(filtered['b'], null);
        expect(filtered['c'], 3);
        expect(filtered['d'], null);

        // Should be updated now
        filtered.listen();
        expect(filtered['a'], null);
        expect(filtered['b'], 5);
        expect(filtered['c'], null);
        expect(filtered['d'], 3);

        rxMap.remove('b');
        expect(filtered['b'], null);
      });

      test('Should dispose when source disposed', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final ObservableMap<String, int> filtered = rxMap.filterItem((final String key, final int value) {
          return value > 1;
        });

        await rxMap.dispose();
        expect(filtered.disposed, true);
      });

      test('Should respect factory when set', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final ObservableMap<String, int> filtered = rxMap.filterItem(
          (final String key, final int value) {
            return value > 1;
          },
          factory: (final Map<String, int>? items) {
            return SplayTreeMap<String, int>.of(
              items ?? <String, int>{},
              (final String a, final String b) => b.compareTo(a),
            );
          },
        );

        filtered.listen();

        expect(filtered.toList(), <int>[3, 2]);

        rxMap['a'] = 0;
        rxMap.remove('b');

        expect(filtered.toList(), <int>[3]);

        rxMap['d'] = 4;
        expect(filtered.toList(), <int>[4, 3]);

        rxMap.remove('c');
        expect(filtered.toList(), <int>[4]);

        rxMap['a'] = 5;
        expect(filtered.toList(), <int>[4, 5]);
      });
    });

    group('mapItem', () {
      test('Should map initial data on listening', () {
        final RxMap<String, int> rxSource = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final ObservableMap<String, String> rxMapped = rxSource.mapItem<String>(
          (final String key, final int value) {
            return '$key$value';
          },
        );

        expect(rxMapped.length, 0);

        rxMapped.listen();

        expect(rxMapped.length, 3);
        expect(rxMapped['a'], 'a1');
        expect(rxMapped['b'], 'b2');
        expect(rxMapped['c'], 'c3');
      });

      test('Should update state when source change', () async {
        final RxMap<String, int> rxSource = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final ObservableMap<String, String> rxMapped = rxSource.mapItem<String>(
          (final String key, final int value) {
            return '$key$value';
          },
        );

        expect(rxMapped.length, 0);

        final Disposable listener = rxMapped.listen();

        rxSource['a'] = 2;
        rxSource.remove('b');

        expect(rxMapped.length, 2);
        expect(rxMapped['a'], 'a2');
        expect(rxMapped['b'], null);
        expect(rxMapped['c'], 'c3');

        await listener.dispose();

        // Should not be updated now
        rxSource['a'] = 0;
        rxSource['b'] = 5;
        rxSource['c'] = 0;
        rxSource['d'] = 3;

        expect(rxMapped['a'], 'a2');
        expect(rxMapped['b'], null);
        expect(rxMapped['c'], 'c3');
        expect(rxMapped['d'], null);

        // Should be updated now
        rxMapped.listen();
        expect(rxMapped['a'], 'a0');
        expect(rxMapped['b'], 'b5');
        expect(rxMapped['c'], 'c0');
        expect(rxMapped['d'], 'd3');
      });

      test('Should dispose when source disposed', () async {
        final RxMap<String, int> rxSource = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final ObservableMap<String, String> rxMapped = rxSource.mapItem<String>(
          (final String key, final int value) {
            return '$key$value';
          },
        );

        await rxSource.dispose();
        expect(rxMapped.disposed, true);
      });

      test('Should respect factory when set', () {
        final RxMap<String, int> rxSource = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final ObservableMap<String, String> rxMapped = rxSource.mapItem<String>(
          (final String key, final int value) {
            return '$key$value';
          },
          factory: (final Map<String, String>? items) {
            return SplayTreeMap<String, String>.of(
              items ?? <String, String>{},
              (final String a, final String b) => b.compareTo(a),
            );
          },
        );

        rxMapped.listen();

        expect(rxMapped.toList(), <String>['c3', 'b2', 'a1']);

        rxSource['a'] = 5;
        rxSource.remove('b');

        expect(rxMapped.toList(), <String>['c3', 'a5']);

        rxSource['d'] = 4;
        expect(rxMapped.toList(), <String>['d4', 'c3', 'a5']);

        rxSource.remove('a');
        expect(rxMapped.toList(), <String>['d4', 'c3']);
      });
    });

    group('changeFactory', () {
      test('Should change the factory', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });

        expect(rxMap.value.values.toList(), <int>[1, 2]);

        final ObservableMap<String, int> rxKeyReversed = rxMap.changeFactory((final Map<String, int>? items) {
          return SplayTreeMap<String, int>.of(
            items ?? <String, int>{},
            (final String a, final String b) => b.compareTo(a),
          );
        });

        rxKeyReversed.listen();

        expect(rxKeyReversed['a'], 1);
        expect(rxKeyReversed['b'], 2);

        expect(rxKeyReversed.value.values.toList(), <int>[2, 1]);

        rxMap['c'] = 0;

        expect(rxKeyReversed.value.values.toList(), <int>[0, 2, 1]);

        rxMap['a'] = 3;
        expect(rxKeyReversed.value.values.toList(), <int>[0, 2, 3]);

        rxMap.remove('b');

        expect(rxKeyReversed.value.values.toList(), <int>[0, 3]);
      });

      test('Should dispose when source disposed', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });

        final ObservableMap<String, int> rxKeyReversed = rxMap.changeFactory((final Map<String, int>? items) {
          return SplayTreeMap<String, int>.of(
            items ?? <String, int>{},
            (final String a, final String b) => b.compareTo(a),
          );
        });

        await rxMap.dispose();
        expect(rxKeyReversed.disposed, true);
      });
    });

    group('transform', () {
      test('Should transform value', () async {
        final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{
          1: 'a',
          2: 'b',
          3: 'c',
        });
        rxSource.add(4, 'd');
        rxSource[1] = 'a2';

        String transformer(final Map<int, String> state) {
          return state.values.join(',');
        }

        final Observable<String> rxTransformed = rxSource.transform<String>(
          initialProvider: transformer,
          onChanged: (final Map<int, String> value, final Emitter<String> emitter) {
            emitter(transformer(value));
          },
        );
        final Disposable listener = rxTransformed.listen();
        expect(rxTransformed.value, 'a2,b,c,d');

        rxSource.add(5, 'e');
        expect(rxTransformed.value, 'a2,b,c,d,e');

        rxSource.remove(2);
        expect(rxTransformed.value, 'a2,c,d,e');

        rxSource[3] = 'c2';
        expect(rxTransformed.value, 'a2,c2,d,e');

        rxSource.clear();
        expect(rxTransformed.value, '');

        await listener.dispose();

        rxSource.add(1, 'a');
        expect(rxTransformed.value, '');

        rxTransformed.listen();
        expect(rxTransformed.value, 'a');

        rxSource.add(2, 'b');
        expect(rxTransformed.value, 'a,b');

        await rxSource.dispose();
        expect(rxTransformed.disposed, true);
      });
    });

    group('transformAs', () {
      group('list', () {
        test('Should transform as a new list', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{
            1: 'a',
            2: 'b',
            3: 'c',
          });
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableList<String> rxReversedUpperCased = rxSource.transformAs.list<String>(
            transform: (
              final ObservableList<String> current,
              final Map<int, String> value,
              final Emitter<List<String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final List<String> newItems = value.values.map((final String item) {
                return item.toUpperCase();
              }).sorted((final String a, final String b) {
                return b.compareTo(a);
              }).toList();

              emitter(newItems);
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <String>['D', 'C', 'B', 'A2']);

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value, <String>['E', 'D', 'C', 'B', 'A2']);

          rxSource.remove(2);
          expect(rxReversedUpperCased.value, <String>['E', 'D', 'C', 'A2']);

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value, <String>['E', 'D', 'C', 'A2']);

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <String>['F', 'E', 'D', 'C2', 'A2']);

          await rxSource.dispose();
          expect(rxReversedUpperCased.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform as a new stateful list', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{
            1: 'a',
            2: 'b',
            3: 'c',
          });
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableStatefulList<String, String> rxReversedUpperCased =
              rxSource.transformAs.statefulList<String, String>(
            transform: (
              final ObservableStatefulList<String, String> current,
              final Map<int, String> value,
              final Emitter<Either<List<String>, String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final List<String> newItems = value.values.map((final String item) {
                return item.toUpperCase();
              }).sorted((final String a, final String b) {
                return b.compareTo(a);
              }).toList();

              emitter(Either<List<String>, String>.left(newItems));
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <String>['D', 'C', 'B', 'A2']);

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value.leftOrThrow, <String>['E', 'D', 'C', 'B', 'A2']);

          rxSource.remove(2);
          expect(rxReversedUpperCased.value.leftOrThrow, <String>['E', 'D', 'C', 'A2']);

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value.leftOrThrow, <String>['E', 'D', 'C', 'A2']);

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <String>['F', 'E', 'D', 'C2', 'A2']);

          await rxSource.dispose();
          expect(rxReversedUpperCased.disposed, true);
        });
      });

      group('map', () {
        test('Should transform as a new map', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableMap<int, String> rxReversedUpperCased = rxSource.transformAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> current,
              final Map<int, String> value,
              final Emitter<Map<int, String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final Map<int, String> newItems = value.map((final int key, final String item) {
                return MapEntry<int, String>(key, item.toUpperCase());
              });

              emitter(newItems);
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D'});

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D', 5: 'E'});

          rxSource.remove(2);
          expect(rxReversedUpperCased.value, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <int, String>{1: 'A2', 3: 'C2', 4: 'D', 5: 'E', 6: 'F'});

          await rxSource.dispose();
          expect(rxReversedUpperCased.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform as a new stateful map', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableStatefulMap<int, String, String> rxReversedUpperCased =
              rxSource.transformAs.statefulMap<int, String, String>(
            transform: (
              final ObservableStatefulMap<int, String, String> current,
              final Map<int, String> value,
              final Emitter<Either<Map<int, String>, String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final Map<int, String> newItems = value.map((final int key, final String item) {
                return MapEntry<int, String>(key, item.toUpperCase());
              });

              emitter(Either<Map<int, String>, String>.left(newItems));
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D'});

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value.leftOrThrow, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D', 5: 'E'});

          rxSource.remove(2);
          expect(rxReversedUpperCased.value.leftOrThrow, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value.leftOrThrow, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <int, String>{1: 'A2', 3: 'C2', 4: 'D', 5: 'E', 6: 'F'});

          await rxSource.dispose();
          expect(rxReversedUpperCased.disposed, true);
        });
      });

      group('set', () {
        test('Should transform on change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{
            1: 'a',
            2: 'b',
            3: 'c',
          });
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableSet<String> rxReversedUpperCased = rxSource.transformAs.set<String>(
            factory: (final Iterable<String>? items) {
              return SplayTreeSet<String>.of(items ?? <String>{}, (final String left, final String right) {
                return right.compareTo(left);
              });
            },
            transform: (
              final ObservableSet<String> current,
              final Map<int, String> value,
              final Emitter<Set<String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final Set<String> newItems = value.values.map((final String item) {
                return item.toUpperCase();
              }).toSet();

              emitter(newItems);
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <String>{'D', 'C', 'B', 'A2'});

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value, <String>{'E', 'D', 'C', 'B', 'A2'});

          rxSource.remove(2);
          expect(rxReversedUpperCased.value, <String>{'E', 'D', 'C', 'A2'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value, <String>{'E', 'D', 'C', 'A2'});

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <String>{'F', 'E', 'D', 'C2', 'A2'});
        });
      });

      group('statefulSet', () {
        test('Should transform as a new stateful set', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{
            1: 'a',
            2: 'b',
            3: 'c',
          });
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableStatefulSet<String, String> rxReversedUpperCased =
              rxSource.transformAs.statefulSet<String, String>(
            transform: (
              final ObservableStatefulSet<String, String> current,
              final Map<int, String> value,
              final Emitter<Either<Set<String>, String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final Set<String> newItems = value.values.map((final String item) {
                return item.toUpperCase();
              }).toSet();

              emitter(Either<Set<String>, String>.left(newItems));
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'D', 'C', 'B', 'A2'});

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'E', 'D', 'C', 'B', 'A2'});

          rxSource.remove(2);
          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'E', 'D', 'C', 'A2'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'E', 'D', 'C', 'A2'});

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'F', 'E', 'D', 'C2', 'A2'});

          await rxSource.dispose();
          expect(rxReversedUpperCased.disposed, true);
        });
      });
    });

    group('transformChangeAs', () {
      group('list', () {
        test('Should transform change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableList<String> rxUppercased = rxSource.transformChangeAs.list<String>(
            transform: (
              final ObservableList<String> current,
              final Map<int, String> state,
              final ObservableMapChange<int, String> change,
              final Emitter<ObservableListUpdateAction<String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final List<String> addItems = <String>[];
              final Set<int> removeIndexes = <int>{};
              final Map<int, String> updatedItems = <int, String>{};

              for (final MapEntry<int, String> entry in change.added.entries) {
                addItems.add(entry.value.toUpperCase());
              }

              for (final String value in change.removed.values) {
                final int index = current.value.indexOf(value.toUpperCase());
                if (index != -1) {
                  removeIndexes.add(index);
                }
              }

              for (final MapEntry<int, ObservableItemChange<String>> entry in change.updated.entries) {
                final String oldValue = entry.value.oldValue.toUpperCase();
                final int index = current.value.indexOf(oldValue);
                if (index != -1) {
                  updatedItems[index] = entry.value.newValue.toUpperCase();
                }
              }

              emitter(
                ObservableListUpdateAction<String>(
                  addItems: addItems,
                  removeAtPositions: removeIndexes,
                  updateItems: updatedItems,
                ),
              );
            },
          );

          final Disposable listener = rxUppercased.listen();

          expect(rxUppercased.value, <String>['A2', 'B', 'C', 'D']);

          rxSource.add(5, 'e');
          expect(rxSource.value, <int, String>{1: 'a2', 2: 'b', 3: 'c', 4: 'd', 5: 'e'});
          expect(rxUppercased.value, <String>['A2', 'B', 'C', 'D', 'E']);

          rxSource.add(6, 'f');
          expect(rxSource.value, <int, String>{1: 'a2', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
          expect(rxUppercased.value, <String>['A2', 'B', 'C', 'D', 'E', 'F']);

          rxSource[1] = 'b2';
          expect(rxSource.value, <int, String>{1: 'b2', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
          expect(rxUppercased.value, <String>['B2', 'B', 'C', 'D', 'E', 'F']);

          rxSource.remove(2);
          expect(rxSource.value, <int, String>{1: 'b2', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
          expect(rxUppercased.value, <String>['B2', 'C', 'D', 'E', 'F']);

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(7, 'g');

          expect(rxUppercased.value, <String>['B2', 'C', 'D', 'E', 'F']);

          rxUppercased.listen();

          expect(rxUppercased.value, <String>['B2', 'C2', 'D', 'E', 'F', 'G']);

          await rxSource.dispose();
          expect(rxUppercased.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableStatefulList<String, String> rxUppercased =
              rxSource.transformChangeAs.statefulList<String, String>(
            transform: (
              final ObservableStatefulList<String, String> current,
              final Map<int, String> state,
              final ObservableMapChange<int, String> change,
              final Emitter<Either<ObservableListUpdateAction<String>, String>> emitter,
            ) {
              if (state.isEmpty) {
                emitter(Either<ObservableListUpdateAction<String>, String>.right('empty'));
                return;
              }

              // map change to list while transforming the value to uppercase
              final List<String> addItems = <String>[];
              final Set<int> removeIndexes = <int>{};
              final Map<int, String> updatedItems = <int, String>{};

              for (final MapEntry<int, String> entry in change.added.entries) {
                addItems.add(entry.value.toUpperCase());
              }

              int indexOf(final String original) {
                return current.value.fold(
                  onLeft: (final List<String> data) => data.indexOf(original.toUpperCase()),
                  onRight: (final _) => -1,
                );
              }

              for (final String value in change.removed.values) {
                final int index = indexOf(value);
                if (index != -1) {
                  removeIndexes.add(index);
                }
              }

              for (final MapEntry<int, ObservableItemChange<String>> entry in change.updated.entries) {
                final int index = indexOf(entry.value.oldValue);
                if (index != -1) {
                  updatedItems[index] = entry.value.newValue.toUpperCase();
                }
              }

              emitter(
                Either<ObservableListUpdateAction<String>, String>.left(
                  ObservableListUpdateAction<String>(
                    addItems: addItems,
                    removeAtPositions: removeIndexes,
                    updateItems: updatedItems,
                  ),
                ),
              );
            },
          );

          final Disposable listener = rxUppercased.listen();

          expect(rxUppercased.value.leftOrThrow, <String>['A2', 'B', 'C', 'D']);

          rxSource.add(5, 'e');
          expect(rxSource.value, <int, String>{1: 'a2', 2: 'b', 3: 'c', 4: 'd', 5: 'e'});
          expect(rxUppercased.value.leftOrThrow, <String>['A2', 'B', 'C', 'D', 'E']);

          rxSource.add(6, 'f');
          expect(rxSource.value, <int, String>{1: 'a2', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
          expect(rxUppercased.value.leftOrThrow, <String>['A2', 'B', 'C', 'D', 'E', 'F']);

          rxSource[1] = 'b2';
          expect(rxSource.value, <int, String>{1: 'b2', 2: 'b', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
          expect(rxUppercased.value.leftOrThrow, <String>['B2', 'B', 'C', 'D', 'E', 'F']);

          rxSource.remove(2);
          expect(rxSource.value, <int, String>{1: 'b2', 3: 'c', 4: 'd', 5: 'e', 6: 'f'});
          expect(rxUppercased.value.leftOrThrow, <String>['B2', 'C', 'D', 'E', 'F']);

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(7, 'g');

          expect(rxUppercased.value.leftOrThrow, <String>['B2', 'C', 'D', 'E', 'F']);

          rxUppercased.listen();

          expect(rxUppercased.value.leftOrThrow, <String>['B2', 'C2', 'D', 'E', 'F', 'G']);

          rxSource.clear();
          expect(rxUppercased.value.leftOrNull, null);
          expect(rxUppercased.value.rightOrThrow, 'empty');

          rxSource[1] = 'a';
          expect(rxUppercased.value.leftOrThrow, <String>['A']);

          await rxSource.dispose();
          expect(rxUppercased.disposed, true);
        });
      });

      group('map', () {
        test('Should transform change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableMap<int, String> rxUppercased = rxSource.transformChangeAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> current,
              final Map<int, String> state,
              final ObservableMapChange<int, String> change,
              final Emitter<ObservableMapUpdateAction<int, String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final Map<int, String> addItems = <int, String>{};
              final Set<int> removeItems = <int>{};

              for (final MapEntry<int, String> entry in change.added.entries) {
                addItems[entry.key] = entry.value.toUpperCase();
              }

              for (final MapEntry<int, String> entry in change.removed.entries) {
                removeItems.add(entry.key);
              }

              for (final MapEntry<int, ObservableItemChange<String>> entry in change.updated.entries) {
                addItems[entry.key] = entry.value.newValue.toUpperCase();
              }

              emitter(
                ObservableMapUpdateAction<int, String>(
                  addItems: addItems,
                  removeKeys: removeItems,
                ),
              );
            },
          );

          final Disposable listener = rxUppercased.listen();

          expect(rxUppercased.value, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D'});

          rxSource.add(5, 'e');
          expect(rxUppercased.value, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D', 5: 'E'});

          rxSource.remove(2);
          expect(rxUppercased.value, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxUppercased.value, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          rxUppercased.listen();

          expect(rxUppercased.value, <int, String>{1: 'A2', 3: 'C2', 4: 'D', 5: 'E', 6: 'F'});

          await rxSource.dispose();
          expect(rxUppercased.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableStatefulMap<int, String, String> rxUppercased =
              rxSource.transformChangeAs.statefulMap<int, String, String>(
            transform: (
              final ObservableStatefulMap<int, String, String> current,
              final Map<int, String> state,
              final ObservableMapChange<int, String> change,
              final Emitter<Either<ObservableMapUpdateAction<int, String>, String>> emitter,
            ) {
              if (state.isEmpty) {
                emitter(Either<ObservableMapUpdateAction<int, String>, String>.right('empty'));
                return;
              }

              // map change to list while transforming the value to uppercase
              final Map<int, String> addItems = <int, String>{};
              final Set<int> removeItems = <int>{};

              for (final MapEntry<int, String> entry in change.added.entries) {
                addItems[entry.key] = entry.value.toUpperCase();
              }

              for (final MapEntry<int, String> entry in change.removed.entries) {
                removeItems.add(entry.key);
              }

              for (final MapEntry<int, ObservableItemChange<String>> entry in change.updated.entries) {
                addItems[entry.key] = entry.value.newValue.toUpperCase();
              }

              emitter(
                Either<ObservableMapUpdateAction<int, String>, String>.left(
                  ObservableMapUpdateAction<int, String>(
                    addItems: addItems,
                    removeKeys: removeItems,
                  ),
                ),
              );
            },
          );

          final Disposable listener = rxUppercased.listen();

          expect(rxUppercased.value.leftOrThrow, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D'});

          rxSource.add(5, 'e');
          expect(rxUppercased.value.leftOrThrow, <int, String>{1: 'A2', 2: 'B', 3: 'C', 4: 'D', 5: 'E'});

          rxSource.remove(2);
          expect(rxUppercased.value.leftOrThrow, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxUppercased.value.leftOrThrow, <int, String>{1: 'A2', 3: 'C', 4: 'D', 5: 'E'});

          rxUppercased.listen();

          expect(rxUppercased.value.leftOrThrow, <int, String>{1: 'A2', 3: 'C2', 4: 'D', 5: 'E', 6: 'F'});

          rxSource.clear();
          expect(rxUppercased.value.rightOrThrow, 'empty');

          rxSource[1] = 'a';
          expect(rxUppercased.value.leftOrThrow, <int, String>{1: 'A'});

          await rxSource.dispose();
          expect(rxUppercased.disposed, true);
        });
      });

      group('set', () {
        test('Should transform change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{
            1: 'a',
            2: 'b',
            3: 'c',
          });
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableSet<String> rxReversedUpperCased = rxSource.transformChangeAs.set<String>(
            factory: (final Iterable<String>? items) {
              return SplayTreeSet<String>.of(items ?? <String>{}, (final String left, final String right) {
                return right.compareTo(left);
              });
            },
            transform: (
              final ObservableSet<String> current,
              final Map<int, String> state,
              final ObservableMapChange<int, String> change,
              final Emitter<ObservableSetUpdateAction<String>> emitter,
            ) {
              // map change to list while transforming the value to uppercase
              final Map<int, String> added = change.added;
              final Map<int, String> removed = change.removed;
              final Map<int, ObservableItemChange<String>> updated = change.updated;

              final Set<String> newItems = <String>{};
              final Set<String> removedItems = <String>{};

              for (final MapEntry<int, String> entry in added.entries) {
                newItems.add(entry.value.toUpperCase());
              }

              for (final MapEntry<int, String> entry in removed.entries) {
                removedItems.add(entry.value.toUpperCase());
              }

              for (final MapEntry<int, ObservableItemChange<String>> entry in updated.entries) {
                newItems.add(entry.value.newValue.toUpperCase());
                removedItems.add(entry.value.oldValue.toUpperCase());
              }

              emitter(
                ObservableSetUpdateAction<String>(
                  addItems: newItems,
                  removeItems: removedItems,
                ),
              );
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <String>{'D', 'C', 'B', 'A2'});

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value, <String>{'E', 'D', 'C', 'B', 'A2'});

          rxSource.remove(2);
          expect(rxReversedUpperCased.value, <String>{'E', 'D', 'C', 'A2'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value, <String>{'E', 'D', 'C', 'A2'});

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value, <String>{'F', 'E', 'D', 'C2', 'A2'});
        });
      });

      group('statefulSet', () {
        test('Should transform change', () async {
          final RxMap<int, String> rxSource = RxMap<int, String>(<int, String>{1: 'a', 2: 'b', 3: 'c'});
          rxSource.add(4, 'd');
          rxSource[1] = 'a2';

          final ObservableStatefulSet<String, String> rxReversedUpperCased =
              rxSource.transformChangeAs.statefulSet<String, String>(
            transform: (
              final ObservableStatefulSet<String, String> current,
              final Map<int, String> state,
              final ObservableMapChange<int, String> change,
              final Emitter<Either<ObservableSetUpdateAction<String>, String>> emitter,
            ) {
              if (state.isEmpty) {
                emitter(Either<ObservableSetUpdateAction<String>, String>.right('empty'));
                return;
              }

              // map change to list while transforming the value to uppercase
              final Map<int, String> added = change.added;
              final Map<int, String> removed = change.removed;
              final Map<int, ObservableItemChange<String>> updated = change.updated;

              final Set<String> newItems = <String>{};
              final Set<String> removedItems = <String>{};

              for (final MapEntry<int, String> entry in added.entries) {
                newItems.add(entry.value.toUpperCase());
              }

              for (final MapEntry<int, String> entry in removed.entries) {
                removedItems.add(entry.value.toUpperCase());
              }

              for (final MapEntry<int, ObservableItemChange<String>> entry in updated.entries) {
                newItems.add(entry.value.newValue.toUpperCase());
                removedItems.add(entry.value.oldValue.toUpperCase());
              }

              emitter(
                Either<ObservableSetUpdateAction<String>, String>.left(
                  ObservableSetUpdateAction<String>(
                    addItems: newItems,
                    removeItems: removedItems,
                  ),
                ),
              );
            },
          );

          final Disposable listener = rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'D', 'C', 'B', 'A2'});

          rxSource.add(5, 'e');
          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'E', 'D', 'C', 'B', 'A2'});

          rxSource.remove(2);
          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'E', 'D', 'C', 'A2'});

          await listener.dispose();

          rxSource[3] = 'c2';
          rxSource.add(6, 'f');

          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'E', 'D', 'C', 'A2'});

          rxReversedUpperCased.listen();

          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'F', 'E', 'D', 'C2', 'A2'});

          rxSource.clear();
          expect(rxReversedUpperCased.value.rightOrThrow, 'empty');

          rxSource[1] = 'a';
          expect(rxReversedUpperCased.value.leftOrThrow, <String>{'A'});

          await rxSource.dispose();
          expect(rxReversedUpperCased.disposed, true);
        });
      });
    });
  });
}
