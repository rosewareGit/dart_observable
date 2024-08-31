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

      test('Transform from Observable', () async {
        final Rx<String> source = Rx<String>('test');
        final ObservableList<String> rxList = source.transformAs.list<String>(
          transform: (
            final ObservableList<String> state,
            final String change,
            final Emitter<ObservableListUpdateAction<String>> emitter,
          ) {
            emitter(
              ObservableListUpdateAction<String>.add(
                <MapEntry<int?, Iterable<String>>>[
                  MapEntry<int?, Iterable<String>>(null, <String>[change]),
                ],
              ),
            );
          },
        );

        expect(rxList.length, 0);
        final Disposable listener = rxList.listen();

        expect(rxList.length, 1);
        expect(rxList[0], 'test');

        source.value = 'test2';

        expect(rxList.length, 2);
        expect(rxList[1], 'test2');

        listener.dispose();

        source.value = 'test3';
        source.value = 'test4';

        expect(rxList.length, 2);

        rxList.listen();

        expect(rxList.length, 4);
        expect(rxList[2], 'test3');
        expect(rxList[3], 'test4');

        await source.dispose();

        expect(rxList.disposed, true);
      });

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
