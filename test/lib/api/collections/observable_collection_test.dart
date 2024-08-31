import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableCollection', () {
    group('flatMapCollectionAsList', () {
      ObservableList<int> createResultList({
        required final RxSet<int> base,
        required final RxList<int> source1,
        required final RxList<int> source2,
      }) {
        final Map<int, ObservableList<int>> mapping = <int, ObservableList<int>>{
          1: source1,
          2: source2,
        };

        return base.flatMapAs.list<int>(
          sourceProvider: (final ObservableSetChange<int> change) {
            final Set<int> added = change.added;
            final Set<ObservableList<int>> removed = <ObservableList<int>>{};

            final Set<ObservableList<int>> newObservables = <ObservableList<int>>{};

            for (final int key in added) {
              final ObservableList<int>? source = mapping[key];
              if (source == null) {
                continue;
              }
              newObservables.add(source);
            }

            for (final int key in change.removed) {
              final ObservableList<int>? source = mapping[key];
              if (source == null) {
                continue;
              }
              removed.add(source);
            }

            return ObservableCollectionFlatMapUpdate<ObservableList<int>>(
              newObservables: newObservables,
              removedObservables: removed,
            );
          },
        );
      }

      test('Should have initial items when listening', () {
        final RxList<int> source1 = RxList<int>(<int>[0]);
        final RxList<int> source2 = RxList<int>();

        final RxSet<int> base = RxSet<int>();
        final ObservableList<int> result = createResultList(
          base: base,
          source1: source1,
          source2: source2,
        );

        expect(result.length, 0);

        base.add(1);
        expect(result.length, 0, reason: 'Should not be updated as we are not listening');
        result.listen();
        expect(result.length, 1, reason: 'Should be updated as we are listening');
      });

      test('Should add items when items added to the base', () {
        final RxList<int> source1 = RxList<int>(<int>[0]);
        final RxList<int> source2 = RxList<int>();

        final RxSet<int> base = RxSet<int>();
        final ObservableList<int> result = createResultList(
          base: base,
          source1: source1,
          source2: source2,
        );

        expect(result.length, 0);

        base.add(1);
        expect(result.length, 0);
        // source1: [0] -> [0, 10, 20, 30]
        // source2: []
        source1.addAll(<int>[10, 20, 30]);

        expect(result.length, 0, reason: 'Should not be updated as we are not listening');
        result.listen();
        expect(result.length, 4, reason: 'Should be updated as we are listening');
        expect(result[0], 0);
        expect(result[1], 10);
        expect(result[2], 20);
        expect(result[3], 30);

        source2.addAll(<int>[11, 21, 31]);

        expect(result.length, 4, reason: 'source2 is not added yet');

        base.add(2);

        expect(result.length, 7, reason: 'source2 is added');
        expect(result[4], 11);
        expect(result[5], 21);
        expect(result[6], 31);
      });

      test('Should remove items when the item is removed from base', () {
        final RxList<int> source1 = RxList<int>();
        final RxList<int> source2 = RxList<int>();

        final RxSet<int> base = RxSet<int>();
        final ObservableList<int> result = createResultList(
          base: base,
          source1: source1,
          source2: source2,
        );

        result.listen();
        base.addAll(<int>[1, 2]);

        source1.addAll(<int>[1, 1, 2, 2, 1]);
        source2.addAll(<int>[2, 2, 3, 3, 1]);
        expect(result.length, 10);

        base.remove(2);

        expect(result.length, 5);
        expect(result.value.listView, <int>[1, 1, 2, 2, 1]);
      });

      test('Should remove items from the result list when removed from the source', () {
        final RxList<int> source1 = RxList<int>();
        final RxList<int> source2 = RxList<int>();

        final RxSet<int> base = RxSet<int>();
        final ObservableList<int> result = createResultList(
          base: base,
          source1: source1,
          source2: source2,
        );

        result.listen();
        base.addAll(<int>[1, 2]);

        source1.addAll(<int>[1, 1, 2, 2, 1]);
        source2.addAll(<int>[2, 2, 3, 3, 1]);
        expect(result.length, 10);

        source2.removeWhere((final int item) => item == 2);

        expect(result.length, 8);
        expect(result.value.listView, <int>[1, 1, 2, 2, 1, 3, 3, 1]);
      });

      test('Should update result when multiple items modified', () {
        final RxList<int> source1 = RxList<int>();
        final RxList<int> source2 = RxList<int>();

        final RxSet<int> base = RxSet<int>();
        final ObservableList<int> result = createResultList(
          base: base,
          source1: source1,
          source2: source2,
        );

        source1.addAll(<int>[1, 2, 3]);
        source2.addAll(<int>[20, 21]);
        base.addAll(<int>[1, 2]);
        result.listen();

        // Apply add, update and remove at once
        // source1: [1, 2, 3] -> [1000, 3, 100, 101]
        // source2: [20, 21]
        source1.applyAction(
          ObservableListUpdateAction<int>(
            insertItemAtPosition: <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(0, <int>[100, 101]),
            ],
            removeIndexes: <int>{1},
            updateItemAtPosition: <int, int>{
              0: 1000,
            },
          ),
        );

        expect(result.length, 6);
        expect(result.value.listView, <int>[1000, 3, 20, 21, 100, 101], reason: 'New items added at the end');
      });

      test('Should dispose when base disposed', () async {
        final RxList<int> source1 = RxList<int>();
        final RxList<int> source2 = RxList<int>();

        final RxSet<int> base = RxSet<int>();
        final ObservableList<int> result = createResultList(
          base: base,
          source1: source1,
          source2: source2,
        );

        result.listen();

        expect(result.disposed, false);

        await base.dispose();

        expect(result.disposed, true);
      });
    });

    group('flatMapCollectionAsMap', () {
      group('Map to map', () {
        test('Should listen on changes from maps', () async {
          final RxMap<String, int> source_1 = RxMap<String, int>();
          final RxMap<String, int> source_2 = RxMap<String, int>();

          final Map<int, ObservableMap<String, int>> byIndex = <int, ObservableMap<String, int>>{
            1: source_1,
            2: source_2,
          };

          final RxSet<int> set = RxSet<int>();
          final ObservableMap<String, int> result = set.flatMapAs.map<String, int>(
            sourceProvider: (final ObservableSetChange<int> change) {
              final Set<int> added = change.added;

              final Set<int> removed = change.removed;
              final Set<ObservableMap<String, int>> removeObservables = <ObservableMap<String, int>>{};
              final Set<ObservableMap<String, int>> newObservables = <ObservableMap<String, int>>{};

              for (final int item in removed) {
                final ObservableMap<String, int>? source = byIndex[item];
                if (source != null) {
                  removeObservables.add(source);
                }
              }

              for (final int key in added) {
                final ObservableMap<String, int>? source = byIndex[key];
                if (source != null) {
                  newObservables.add(source);
                }
              }

              return ObservableCollectionFlatMapUpdate<ObservableMap<String, int>>(
                newObservables: newObservables,
                removedObservables: removeObservables,
              );
            },
          );

          expect(result.length, 0);

          set.add(1);
          expect(result.length, 0);
          source_1.addAll(<String, int>{'a': 1, 'b': 2, 'c': 3});

          expect(result.length, 0, reason: 'Should not be updated as we are not listening');
          result.listen();
          expect(result.length, 3, reason: 'Should be updated as we are listening');
          expect(result['a'], 1);
          expect(result['b'], 2);
          expect(result['c'], 3);

          source_1.addAll(<String, int>{'d': 4, 'e': 5, 'f': 6});
          expect(result.length, 6);
          expect(result['d'], 4);
          expect(result['e'], 5);
          expect(result['f'], 6);

          set.add(2);
          source_2.addAll(<String, int>{'g': 7, 'h': 8, 'i': 9});
          expect(result.length, 9);
          expect(result['g'], 7);
          expect(result['h'], 8);
          expect(result['i'], 9);

          set.remove(1);
          expect(result.length, 3);
          expect(result['g'], 7);
          expect(result['h'], 8);
          expect(result['i'], 9);

          set.remove(2);
          expect(result.length, 0);

          source_1.addAll(<String, int>{'j': 10, 'k': 11, 'l': 12});
          expect(result.length, 0);

          set.addAll(<int>[1, 2]);
          expect(result.length, 12);

          source_1.applyAction(
            ObservableMapUpdateAction<String, int>(
              removeItems: <String>{'a', 'b', 'c'},
              addItems: <String, int>{'m': 13, 'n': 14, 'o': 15},
            ),
          );

          expect(result.length, 12);
          expect(result['m'], 13);
          expect(result['n'], 14);
          expect(result['o'], 15);
          expect(result['a'], null);
          expect(result['b'], null);
          expect(result['c'], null);

          await set.dispose();
          expect(result.disposed, true);
        });
      });
    });

    group('flatMapCollectionAsSet', () {
      test('Should listen on changes from set', () async {
        final RxSet<String> source_1 = RxSet<String>();
        final RxSet<String> source_2 = RxSet<String>();

        final Map<int, ObservableSet<String>> byIndex = <int, ObservableSet<String>>{
          1: source_1,
          2: source_2,
        };

        final RxSet<int> set = RxSet<int>();

        final ObservableSet<String> result = set.flatMapAs.set<String>(
          sourceProvider: (final ObservableSetChange<int> change) {
            final Set<int> added = change.added;

            final Set<ObservableSet<String>> newObservables = <ObservableSet<String>>{};

            for (final int key in added) {
              final ObservableSet<String>? source = byIndex[key];
              if (source != null) {
                newObservables.add(source);
              }
            }

            final Set<ObservableSet<String>> removed = <ObservableSet<String>>{};

            for (final int key in change.removed) {
              final ObservableSet<String>? source = byIndex[key];
              if (source != null) {
                removed.add(source);
              }
            }

            return ObservableCollectionFlatMapUpdate<ObservableSet<String>>(
              newObservables: newObservables,
              removedObservables: removed,
            );
          },
        );

        expect(result.length, 0);

        set.add(1);
        expect(result.length, 0);
        source_1.addAll(<String>['a', 'b', 'c']);

        expect(result.length, 0, reason: 'Should not be updated as we are not listening');
        result.listen();
        expect(result.length, 3, reason: 'Should be updated as we are listening');

        source_1.addAll(<String>['d', 'e', 'f']);
        expect(result.length, 6);

        set.add(2);
        source_2.addAll(<String>['g', 'h', 'i']);
        expect(result.length, 9);

        set.remove(1);
        expect(result.length, 3);

        set.remove(2);
        expect(result.length, 0);

        source_1.addAll(<String>['j', 'k', 'l']);
        expect(result.length, 0);

        set.addAll(<int>[1, 2]);
        expect(result.length, 12);

        await set.dispose();
        expect(result.disposed, true);
      });
    });
  });
}
