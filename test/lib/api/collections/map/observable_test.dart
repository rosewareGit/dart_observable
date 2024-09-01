import 'dart:async';
import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

class TestModel {
  final int value;

  TestModel(this.value);
}

void main() {
  group('ObservableMap', () {
    group('sorted', () {
      test('Should create an observable', () {
        final ObservableMap<String, int> rxSorted = ObservableMap<String, int>.sorted(
          comparator: (final int left, final int right) {
            return right.compareTo(left);
          },
          initial: <String, int>{
            'a': 1,
            'b': 2,
            'c': 3,
          },
        );

        rxSorted.listen();

        expect(rxSorted.length, 3);
        expect(rxSorted['a'], 1);
        expect(rxSorted['b'], 2);
        expect(rxSorted['c'], 3);
        expect(rxSorted.toList(), <int>[3, 2, 1]);
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
            removeItems: <String>{},
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
            removeItems: <String>{'a'},
            addItems: <String, int>{
              'c': 3,
            },
          ),
        );

        expect(map.length, 2);
        expect(map['a'], null);
        expect(map['b'], 2);
        expect(map['c'], 3);

        await listener.dispose();

        streamController.add(
          ObservableMapUpdateAction<String, int>(
            removeItems: <String>{'b'},
            addItems: <String, int>{
              'd': 4,
            },
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
    });

    group('mapMap', () {
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
    });

    group('changeFactory', () {
      test('Should change the factory', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });

        expect(rxMap.value.mapView.values.toList(), <int>[1, 2]);

        final ObservableMap<String, int> rxKeyReversed = rxMap.changeFactory((final Map<String, int>? items) {
          return SplayTreeMap<String, int>.of(
            items ?? <String, int>{},
            (final String a, final String b) => b.compareTo(a),
          );
        });

        rxKeyReversed.listen();

        expect(rxKeyReversed['a'], 1);
        expect(rxKeyReversed['b'], 2);

        expect(rxKeyReversed.value.mapView.values.toList(), <int>[2, 1]);

        rxMap['c'] = 0;

        expect(rxKeyReversed.value.mapView.values.toList(), <int>[0, 2, 1]);

        rxMap['a'] = 3;
        expect(rxKeyReversed.value.mapView.values.toList(), <int>[0, 2, 3]);

        rxMap.remove('b');

        expect(rxKeyReversed.value.mapView.values.toList(), <int>[0, 3]);
      });
    });
  });
}
