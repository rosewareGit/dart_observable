import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('OperatorsTransformLists', () {
    group('UndefinedFailure', () {
      ObservableListUndefinedFailure<int, String> createStateFromSet(final RxSet<int> source) {
        return source.transformAs.lists.undefinedFailure<int, String>(
          transform: (
            final ObservableListUndefinedFailure<int, String> state,
            final ObservableSetChange<int> change,
            final Emitter<StateOf<ObservableListUpdateAction<int>, UndefinedFailure<String>>> updater,
          ) {
            final Set<int> added = change.added;
            final Set<int> removed = change.removed;

            final List<int> addItems = <int>[];
            final Set<int> removePositions = <int>{};

            for (final int key in added) {
              addItems.add(key * 2);
            }

            final ObservableListStatefulState<int, UndefinedFailure<String>> currentData = state.value;
            currentData.when(
              onData: (final ObservableListState<int> data) {
                for (final int key in removed) {
                  final int index = data.listView.indexOf(key * 2);
                  if (index != -1) {
                    removePositions.add(index);
                  }
                }
              },
            );

            updater(
              StateOf<ObservableListUpdateAction<int>, UndefinedFailure<String>>.data(
                ObservableListUpdateAction<int>(
                  removeIndexes: removePositions,
                  insertItemAtPosition: <MapEntry<int?, Iterable<int>>>[
                    MapEntry<int?, Iterable<int>>(null, addItems),
                  ],
                ),
              ),
            );
          },
        );
      }

      test('Should apply transform from set', () async {
        final RxSet<int> source = RxSet<int>(initial: <int>[1, 2]);

        final ObservableListUndefinedFailure<int, String> rxResult = createStateFromSet(source);

        Disposable? listener = rxResult.listen();

        expect(rxResult.value.data!.listView, <int>[2, 4]);

        source.add(3);
        expect(rxResult.value.data!.listView, <int>[2, 4, 6]);

        await listener.dispose();

        source.addAll(<int>[4, 5]);

        expect(rxResult.value.data!.listView, <int>[2, 4, 6]);

        listener = rxResult.listen();
        expect(rxResult.value.data!.listView, <int>[2, 4, 6, 8, 10]);

        source.remove(2);
        expect(rxResult.value.data!.listView, <int>[2, 6, 8, 10]);
      });
    });
  });
}
