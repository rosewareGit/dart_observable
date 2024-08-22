import 'dart:collection';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableCollectionTransforms', () {
    group('list', () {
      ObservableList<String> createListFromSet(final RxSet<int> source) {
        return source.transformAs.list<String>(
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

        final ObservableList<String> result = createListFromSet(source);

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

      test('Should dispose when base is disposed', () async {
        final RxSet<int> source = RxSet<int>(<int>[1, 2]);

        final ObservableList<String> result = createListFromSet(source);

        result.listen();

        expect(result.disposed, false);

        await source.dispose();

        expect(result.disposed, true);
      });
    });
  });
}
