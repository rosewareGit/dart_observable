import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableList', () {
    group('just', () {
      test('Should create an empty ObservableList', () {
        final ObservableList<int> rxList = ObservableList<int>.just(<int>[]);
        expect(rxList.length, 0);
        expect(rxList.value.listView, <int>[]);
      });

      test('Should create an ObservableList with the specified value', () {
        final ObservableList<int> rxList = ObservableList<int>.just(<int>[1, 2, 3]);
        expect(rxList.length, 3);
        expect(rxList.value.listView, <int>[1, 2, 3]);
      });
    });

    group('fromStream', () {
      test('Should create an ObservableList from the specified stream', () async {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(
          stream: controller.stream,
          initial: <int>[0],
        );
        rxList.listen();

        controller.add(ObservableListUpdateAction<int>(addItems: <int>[1, 2]));
        expect(rxList.length, 3);
        expect(rxList.value.listView, <int>[0, 1, 2]);

        controller.add(
          ObservableListUpdateAction<int>(
            insertAt: <int, Iterable<int>>{
              0: <int>[3, 4],
            },
          ),
        );
        expect(rxList.length, 5);
        expect(rxList.value.listView, <int>[3, 4, 0, 1, 2]);

        controller.add(ObservableListUpdateAction<int>(removeItems: <int>{0}));
        expect(rxList.length, 4);
        expect(rxList.value.listView, <int>[4, 0, 1, 2]);

        await controller.close();
        await rxList.dispose();

        expect(rxList.disposed, true);
      });

      test('Should handle stream errors when onError is set', () async {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(
          stream: controller.stream,
          initial: <int>[0],
          onError: (final dynamic error) {
            return <int>[-1];
          },
        );
        rxList.listen();

        controller.addError(Exception('Stream error'));

        expect(rxList.length, 1);
        expect(rxList.value.listView, <int>[-1]);

        await controller.close();
        await rxList.dispose();

        expect(rxList.disposed, true);
      });

      test('Should handle error when onError is set without returning a new list', () {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(
          stream: controller.stream,
          initial: <int>[0],
          onError: (final dynamic error) {
            return null;
          },
        );
        rxList.listen();

        controller.addError(Exception('Stream error'));

        expect(rxList.length, 1);
        expect(rxList.value.listView, <int>[0]);
      });

      test('Should propagate error to downstream handler', () {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(
          stream: controller.stream,
          initial: <int>[0],
        );

        bool errorReceived = false;

        rxList.listen(
          onError: (final dynamic error, final StackTrace stack) {
            errorReceived = true;
            expect(error, isException);
          },
        );
        controller.addError(Exception('Stream error'));

        expect(errorReceived, true);
      });

      test('Should throw stream errors when onError is not set', () async {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(stream: controller.stream, initial: <int>[0]);

        bool catchError = false;

        runZonedGuarded(() {
          rxList.listen();
        }, (final Object error, final _) {
          catchError = true;
          expect(error, isA<StateError>());
          expect((error as StateError).message, 'Stream error');
        });

        controller.addError(StateError('Stream error'));

        expect(catchError, true);

        expect(rxList.length, 1);
        expect(rxList.value.listView, <int>[0]);

        await controller.close();
        await rxList.dispose();

        expect(rxList.disposed, true);
      });

      test('Should handle multiple rapid updates from the stream', () {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(stream: controller.stream, initial: <int>[0]);
        rxList.listen();

        controller.add(ObservableListUpdateAction<int>(addItems: <int>[1]));
        controller.add(ObservableListUpdateAction<int>(addItems: <int>[2]));
        controller.add(ObservableListUpdateAction<int>(addItems: <int>[3]));

        expect(rxList.length, 4);
        expect(rxList.value.listView, <int>[0, 1, 2, 3]);
      });

      test('Should update the list with all the pending changes after listening', () async {
        final StreamController<ObservableListUpdateAction<int>> controller =
            StreamController<ObservableListUpdateAction<int>>(sync: true);

        final ObservableList<int> rxList = ObservableList<int>.fromStream(stream: controller.stream, initial: <int>[0]);

        controller.add(ObservableListUpdateAction<int>(addItems: <int>[1]));
        controller.add(ObservableListUpdateAction<int>(addItems: <int>[2]));
        controller.add(ObservableListUpdateAction<int>(addItems: <int>[3]));

        Disposable listener = rxList.listen();

        expect(rxList.length, 4);
        expect(rxList.value.listView, <int>[0, 1, 2, 3]);

        await listener.dispose();

        controller.add(ObservableListUpdateAction<int>(addItems: <int>[4]));
        controller.add(ObservableListUpdateAction<int>(addItems: <int>[5]));

        listener = rxList.listen();

        expect(rxList.length, 6);
        expect(rxList.value.listView, <int>[0, 1, 2, 3, 4, 5]);
      });
    });

    group('merged', () {
      test('Should create an ObservableList from the specified collections', () {
        final RxList<int> source1 = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final RxList<int> source2 = RxList<int>(<int>[4, 5, 6]);
        final RxList<int> source3 = RxList<int>(<int>[6, 6, 6]);

        final ObservableList<int> rxList = ObservableList<int>.merged(
          collections: <ObservableList<int>>[source1, source2, source3],
        );

        rxList.listen();

        expect(rxList.length, 11);
        expect(rxList.value.listView, <int>[1, 2, 3, 4, 5, 4, 5, 6, 6, 6, 6]);

        source1.add(7);
        expect(source1.value.listView, <int>[1, 2, 3, 4, 5, 7]);
        expect(rxList.length, 12);
        expect(rxList.value.listView, <int>[1, 2, 3, 4, 5, 7, 4, 5, 6, 6, 6, 6]);

        source2.add(7);
        expect(source2.value.listView, <int>[4, 5, 6, 7]);
        expect(rxList.length, 13);
        expect(rxList.value.listView, <int>[1, 2, 3, 4, 5, 7, 4, 5, 6, 7, 6, 6, 6]);

        source1.removeAt(0);
        expect(source1.value.listView, <int>[2, 3, 4, 5, 7]);
        expect(rxList.length, 12);
        expect(rxList.value.listView, <int>[2, 3, 4, 5, 7, 4, 5, 6, 7, 6, 6, 6]);

        source2.removeAt(0);
        expect(source2.value.listView, <int>[5, 6, 7]);
        expect(rxList.length, 11);
        expect(rxList.value.listView, <int>[2, 3, 4, 5, 7, 5, 6, 7, 6, 6, 6]);

        source1[0] = 10;
        expect(source1.value.listView, <int>[10, 3, 4, 5, 7]);
        expect(rxList.length, 11);
        expect(rxList.value.listView, <int>[10, 3, 4, 5, 7, 5, 6, 7, 6, 6, 6]);

        source2[0] = 12;
        expect(source2.value.listView, <int>[12, 6, 7]);
        expect(rxList.length, 11);
        expect(rxList.value.listView, <int>[10, 3, 4, 5, 7, 12, 6, 7, 6, 6, 6]);
      });

      test('Should handle merging with an empty source list', () {
        final RxList<int> source1 = RxList<int>(<int>[1, 2, 3]);
        final RxList<int> source2 = RxList<int>(<int>[]);
        final RxList<int> source3 = RxList<int>(<int>[4, 5]);

        final ObservableList<int> rxList = ObservableList<int>.merged(
          collections: <ObservableList<int>>[source1, source2, source3],
        );

        rxList.listen();

        expect(rxList.length, 5);
        expect(rxList.value.listView, <int>[1, 2, 3, 4, 5]);

        source1.add(6);
        expect(rxList.length, 6);
        expect(rxList.value.listView, <int>[1, 2, 3, 6, 4, 5]);

        source3.add(7);
        expect(rxList.length, 7);
        expect(rxList.value.listView, <int>[1, 2, 3, 6, 4, 5, 7]);
      });

      test('Should handle merging with overlapping elements', () {
        final RxList<int> source1 = RxList<int>(<int>[1, 2, 3]);
        final RxList<int> source2 = RxList<int>(<int>[3, 4, 5]);
        final RxList<int> source3 = RxList<int>(<int>[5, 6, 7]);

        final ObservableList<int> rxList = ObservableList<int>.merged(
          collections: <ObservableList<int>>[source1, source2, source3],
        );

        rxList.listen();

        expect(rxList.length, 9);
        expect(rxList.value.listView, <int>[1, 2, 3, 3, 4, 5, 5, 6, 7]);

        source1.add(8);
        expect(rxList.length, 10);
        expect(rxList.value.listView, <int>[1, 2, 3, 8, 3, 4, 5, 5, 6, 7]);

        source2.remove(3);
        expect(rxList.length, 9);
        expect(rxList.value.listView, <int>[1, 2, 3, 8, 4, 5, 5, 6, 7]);

        source3[0] = 9;
        expect(rxList.length, 9);
        expect(rxList.value.listView, <int>[1, 2, 3, 8, 4, 5, 9, 6, 7]);
      });
    });

    group('operator []', () {
      test('Should return the item at the specified index', () {
        final ObservableList<int> rxList = RxList<int>(<int>[1, 2, 3]);

        expect(rxList[0], 1);
        expect(rxList[1], 2);
        expect(rxList[2], 3);
      });
    });

    group('listen', () {
      test('Should emit updated state', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final List<ObservableListChange<int>> changes = <ObservableListChange<int>>[];
        rxList.listen(
          onChange: (final ObservableListState<int> state) {
            changes.add(rxList.change);
          },
        );
        rxList.add(4);
        expect(changes[0].added[3], 4);

        rxList.removeAt(0);
        expect(changes[1].removed[0], 1);

        rxList.insert(0, 5);
        expect(changes[2].added[0], 5);

        rxList.insertAll(1, <int>[6, 7]);
        expect(changes[3].added[1], 6);
        expect(changes[3].added[2], 7);

        rxList[0] = 8;
        expect(changes[4].updated[0]!.oldValue, 5);
        expect(changes[4].updated[0]!.newValue, 8);
      });
    });

    group('onChange', () {
      test('Should emit change', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final List<ObservableListChange<int>> changes = <ObservableListChange<int>>[];
        rxList.onChange(
          onChange: (final ObservableListChange<int> change) {
            changes.add(change);
          },
        );
        rxList.add(4);
        expect(changes[0].added[3], 4);

        rxList.removeAt(0);
        expect(changes[1].removed[0], 1);

        rxList.insert(0, 5);
        expect(changes[2].added[0], 5);

        rxList.insertAll(1, <int>[6, 7]);
        expect(changes[3].added[1], 6);
        expect(changes[3].added[2], 7);

        rxList[0] = 8;
        expect(changes[4].updated[0]!.oldValue, 5);
        expect(changes[4].updated[0]!.newValue, 8);
      });
    });

    group('length', () {
      test('Should return the length of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        expect(rxList.length, 3);
        rxList.removeAt(0);
        expect(rxList.length, 2);
        rxList.add(4);
        expect(rxList.length, 3);
      });
    });

    group('rxItem', () {
      test('Should return the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);

        rxItem.listen();

        expect(rxItem.value, 1);
        rxList[0] = 4;
        expect(rxItem.value, 4);
      });

      test('Should be the next item when item at the specified index is removed', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);

        rxItem.listen();

        expect(rxItem.value, 1);
        rxList.removeAt(0);
        expect(rxItem.value, 2);
      });

      test('Should update when item at the specified index is updated', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);

        rxItem.listen();

        expect(rxItem.value, 1);
        rxList[0] = 4;
        expect(rxItem.value, 4);
      });

      test('Should be the updated item after listening', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);
        expect(rxItem.value, 1);
        rxList.removeAt(0);
        rxItem.listen();
        expect(rxItem.value, 2);
      });

      test('Should dispose when source is disposed', () async {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);
        expect(rxItem.value, 1);
        await rxList.dispose();
        expect(rxItem.disposed, true);
      });

      test('Should pause when inactive', () async {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);

        final Observable<int?> rxItem = rxList.rxItem(0);
        Disposable listener = rxItem.listen();

        expect(rxItem.value, 1);
        await listener.dispose();

        rxList[0] = 4;
        expect(rxItem.value, 1);

        listener = rxItem.listen();
        expect(rxItem.value, 4);
      });

      test('Should be null if index is not set yet', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);

        final Observable<int?> rxItem = rxList.rxItem(3);
        expect(rxItem.value, null);
        rxItem.listen();

        expect(rxItem.value, null);

        rxList.add(4);

        expect(rxItem.value, 4);
      });
    });

    group('sorted', () {
      test('Should sort the initial list', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        final ObservableList<int> rxSorted = rxSource.sorted((final int left, final int right) {
          return right.compareTo(left);
        });

        rxSorted.listen();

        expect(rxSorted.length, 10);
        expect(rxSorted.value.listView, <int>[10, 9, 8, 7, 6, 5, 4, 3, 2, 1]);
      });

      test('Should update list on source change', () async {
        final RxList<int> rxSource = RxList<int>(<int>[1]);
        final ObservableList<int> rxSorted = rxSource.sorted((final int left, final int right) {
          return right.compareTo(left);
        });

        ObservableListChange<int>? lastChange;
        rxSorted.onChange(
          onChange: (final ObservableListChange<int> change) {
            lastChange = change;
          },
        );

        expect(rxSorted.length, 1);
        expect(rxSorted.value.listView, <int>[1]);
        expect(lastChange!.added[0], 1);

        rxSource.add(5);
        expect(rxSorted.length, 2);
        expect(rxSorted.value.listView, <int>[5, 1]);
        expect(lastChange!.added[0], 5);

        rxSource.add(3);
        expect(rxSorted.length, 3);
        expect(rxSorted.value.listView, <int>[5, 3, 1]);
        expect(lastChange!.added[1], 3);

        rxSource.add(7);
        expect(rxSource.value.listView, <int>[1, 5, 3, 7]);
        expect(rxSorted.length, 4);
        expect(rxSorted.value.listView, <int>[7, 5, 3, 1]);
        expect(lastChange!.added[0], 7);

        rxSource.insert(0, 2);
        expect(rxSource.value.listView, <int>[2, 1, 5, 3, 7]);
        expect(rxSorted.length, 5);
        expect(rxSorted.value.listView, <int>[7, 5, 3, 2, 1]);
        expect(lastChange!.added[3], 2);

        rxSource.removeAt(0);
        expect(rxSource.value.listView, <int>[1, 5, 3, 7]);
        expect(rxSorted.length, 4);
        expect(rxSorted.value.listView, <int>[7, 5, 3, 1]);
        expect(lastChange!.removed[3], 2);

        rxSource[2] = 10;
        expect(rxSource.value.listView, <int>[1, 5, 10, 7]);
        expect(rxSorted.length, 4);
        expect(rxSorted.value.listView, <int>[10, 7, 5, 1]);
        expect(lastChange!.updated[2]!.oldValue, 3);
        expect(lastChange!.updated[2]!.newValue, 10);

        await rxSource.dispose();
        expect(rxSorted.disposed, true);
      });
    });

    group('filterItem', () {
      test('Should filter initial source list on listen', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        final ObservableList<int> filteredList = rxSource.filterItem((final int item) => item % 2 == 0);

        expect(filteredList.length, 0);

        filteredList.listen();

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10]);
      });

      test('Should filter source list on change', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        final ObservableList<int> filteredList = rxSource.filterItem((final int item) => item % 2 == 0);

        final List<ObservableListChange<int>> changes = <ObservableListChange<int>>[];
        filteredList.onChange(
          onChange: (final ObservableListChange<int> change) {
            changes.add(change);
          },
        );

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10]);
        expect(changes[0].added.length, 5);

        rxSource.add(11);
        expect(rxSource.value.listView, <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10]);

        rxSource.add(12);
        expect(rxSource.value.listView, <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 6);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10, 12]);
        expect(changes[1].added[5], 12);

        rxSource.removeAt(0);
        expect(rxSource.value.listView, <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 6);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10, 12]);
        expect(changes.length, 2);

        rxSource.removeAt(0);
        expect(rxSource.value.listView, <int>[3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[4, 6, 8, 10, 12]);
        expect(changes[2].removed[0], 2);

        rxSource[1] = 20;
        expect(rxSource.value.listView, <int>[3, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[20, 6, 8, 10, 12]);
        expect(changes[3].updated[0]!.oldValue, 4);
        expect(changes[3].updated[0]!.newValue, 20);

        rxSource[1] = 3;
        expect(rxSource.value.listView, <int>[3, 3, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 4);
        expect(filteredList.value.listView, <int>[6, 8, 10, 12]);
        expect(changes[4].removed[0], 20);

        rxSource.removeAt(0);
        expect(rxSource.value.listView, <int>[3, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 4);
        expect(filteredList.value.listView, <int>[6, 8, 10, 12]);
        expect(changes.length, 5);

        rxSource.removeAt(2);
        expect(rxSource.value.listView, <int>[3, 5, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 3);
        expect(filteredList.value.listView, <int>[8, 10, 12]);
        expect(changes[5].removed[0], 6);
      });
    });

    group('mapItem', () {
      test('Should map initial items on listen', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5']);
      });

      test('Should map changes', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5']);

        rxSource.add(6);

        expect(rxMapped.length, 6);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5', '6']);

        rxSource.removeAt(0);

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['2', '3', '4', '5', '6']);

        rxSource[0] = 7;

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['7', '3', '4', '5', '6']);
      });

      test('Should dispose when source disposed', () async {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5']);

        await rxSource.dispose();

        expect(rxMapped.disposed, true);
      });
    });

    group('switchMap', () {
      test('Should switch to the new observable and listen', () async {
        final RxInt rxType1 = RxInt(1);
        final RxInt rxType2 = RxInt(2);
        final RxInt rxType3 = RxInt(3);

        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3]);

        final Observable<int> rxSwitched = rxSource.switchMap<int>(
          (final ObservableListState<int> state) {
            final int mod = state.listView.length % 3;
            if (mod == 0) {
              return rxType1;
            } else if (mod == 1) {
              return rxType2;
            } else {
              return rxType3;
            }
          },
        );

        final Disposable listener = rxSwitched.listen();

        expect(rxSwitched.value, 1);
        rxType1.value = 4;
        expect(rxSwitched.value, 4);

        rxSource.add(4);
        expect(rxSwitched.value, 2, reason: 'Should switch to rxType2 because 4 % 3 == 1');
        rxType2.value = 5;
        expect(rxSwitched.value, 5);

        rxSource.add(5);
        expect(rxSwitched.value, 3, reason: 'Should switch to rxType3 because 5 % 3 == 2');
        rxType3.value = 6;
        expect(rxSwitched.value, 6);

        rxSource.removeAt(0);
        expect(rxSwitched.value, 5, reason: 'Should switch to rxType2 because 5 % 3 == 2');

        await listener.dispose();

        rxSource.add(6);
        expect(rxSwitched.value, 5, reason: 'Should not switch because listener is disposed');

        rxSwitched.listen();
        // Should switch after listening again
        expect(rxSwitched.value, 6, reason: 'Should switch to rxType3 because 6 % 3 == 0');

        final Observable<int> rxSwitched2 = rxSource.switchMap<int>(
          (final ObservableListState<int> state) {
            final int mod = state.listView.length % 3;
            if (mod == 0) {
              return rxType1;
            } else if (mod == 1) {
              return rxType2;
            } else {
              return rxType3;
            }
          },
        );

        rxSwitched2.listen();
        expect(rxSwitched2.value, 6, reason: 'Should switch to rxType3 because 6 % 3 == 0');

        await rxSource.dispose();
        expect(rxSwitched.disposed, true);
        expect(rxSwitched2.disposed, true);
      });
    });

    group('switchMapAs', () {
      group('map', () {
        test('Should switch to the new observable and listen', () async {
          final RxMap<int, String> rxType1 = RxMap<int, String>(<int, String>{1: '1'});
          final RxMap<int, String> rxType2 = RxMap<int, String>(<int, String>{2: '2'});
          final RxMap<int, String> rxType3 = RxMap<int, String>(<int, String>{3: '3'});

          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3]);

          final ObservableMap<int, String> rxSwitched = rxSource.switchMapAs.map<int, String>(
            mapper: (final ObservableListState<int> state) {
              final int mod = state.listView.length % 3;
              if (mod == 0) {
                return rxType1;
              } else if (mod == 1) {
                return rxType2;
              } else {
                return rxType3;
              }
            },
          );

          rxSwitched.listen();

          expect(rxSwitched.length, 1);
          expect(rxSwitched.value.mapView, <int, String>{1: '1'});

          rxType1[1] = '4';
          expect(rxSwitched.value.mapView, <int, String>{1: '4'});
          rxType1[2] = '5';
          expect(rxSwitched.value.mapView, <int, String>{1: '4', 2: '5'});

          rxSource.add(4);
          expect(rxSwitched.length, 1);
          expect(rxSwitched.value.mapView, <int, String>{2: '2'});

          rxSource.remove(4);
          expect(rxSwitched.length, 2);
          expect(rxSwitched.value.mapView, <int, String>{1: '4', 2: '5'});

          await rxSource.dispose();
          expect(rxSwitched.disposed, true);
        });
      });
    });

    group('operators', () {
      test('Chaining operators should emit update', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxResult = rxSource //
            .filterItem((final int item) => item % 2 == 0)
            .mapItem<String>((final int item) => item.toString());

        rxResult.listen();

        expect(rxResult.value.listView.length, 2);
      });
    });
  });
}
