import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableCollection', () {
    group('flatMapCollectionAsMap', () {
      test('Should listen on changes from set', () async {
        final RxSet<String> source_1 = RxSet<String>();
        final RxSet<String> source_2 = RxSet<String>();

        final RxSet<int> set = RxSet<int>();

        final ObservableSet<String> result = set.flatMapCollectionAsSet<String>(
          sourceProvider: (final ObservableSetChange<int> change) {
            final Set<int> added = change.added;
            final Set<int> removed = change.removed;

            final Map<int, ObservableSet<String>> newObservables = <int, ObservableSet<String>>{};

            for (final int key in added) {
              if (key == 1) {
                newObservables[key] = source_1;
              } else if (key == 2) {
                newObservables[key] = source_2;
              }
            }

            return ObservableCollectionFlatMapUpdate<int, String, ObservableSet<String>>(
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

    group('transformCollectionAsList', () {
      ObservableList<String> createResultFromSource(final RxSet<int> source) {
        return source.transformCollectionAsList<String>(
          transform: (
            final ObservableList<String> state,
            final ObservableSetChange<int> change,
            final Emitter<ObservableListUpdateAction<String>> updater,
          ) {
            final Set<int> added = change.added;
            final Set<int> removed = change.removed;

            final List<String> addItems = <String>[];
            final Set<int> removePositions = <int>{};

            for (final int key in added) {
              addItems.add('item-$key');
            }

            final UnmodifiableListView<String> currentData = state.value.listView;
            for (final int key in removed) {
              final int index = currentData.indexOf('item-$key');
              if (index != -1) {
                removePositions.add(index);
              }
            }

            if (removePositions.isNotEmpty) {
              updater(
                ObservableListUpdateAction<String>.remove(removePositions),
              );
            }

            if (addItems.isNotEmpty) {
              updater(
                ObservableListUpdateAction<String>.add(
                  <MapEntry<int?, Iterable<String>>>[MapEntry<int?, Iterable<String>>(null, addItems)],
                ),
              );
            }
          },
        );
      }

      test('Should apply transform from set', () async {
        final RxSet<int> source = RxSet<int>(<int>[1, 2]);

        final ObservableList<String> result = createResultFromSource(source);

        Disposable? listener = result.listen();

        expect(result.value.listView, <String>['item-1', 'item-2']);

        source.add(3);
        expect(result.value.listView, <String>['item-1', 'item-2', 'item-3']);

        await listener.dispose();

        source.addAll(<int>[4, 5]);

        expect(result.value.listView, <String>['item-1', 'item-2', 'item-3']);

        listener = result.listen();
        expect(result.value.listView, <String>['item-1', 'item-2', 'item-3', 'item-4', 'item-5']);

        source.remove(2);
        expect(result.value.listView, <String>['item-1', 'item-3', 'item-4', 'item-5']);
      });

      test('Should dispose when source is disposed', () async {
        final RxSet<int> source = RxSet<int>(<int>[1, 2]);

        final ObservableList<String> result = createResultFromSource(source);

        result.listen();

        expect(result.disposed, false);

        await source.dispose();

        expect(result.disposed, true);
      });
    });
  });
}
