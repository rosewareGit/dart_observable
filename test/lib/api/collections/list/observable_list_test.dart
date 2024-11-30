import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableList', () {
    group('just', () {
      test('Should create an empty ObservableList', () {
        final ObservableList<int> rxList = ObservableList<int>.just(<int>[]);
        expect(rxList.length, 0);
        expect(rxList.value, <int>[]);
      });

      test('Should create an ObservableList with the specified value', () {
        final ObservableList<int> rxList = ObservableList<int>.just(<int>[1, 2, 3]);
        expect(rxList.length, 3);
        expect(rxList.value, <int>[1, 2, 3]);
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
        expect(rxList.value, <int>[0, 1, 2]);

        controller.add(
          ObservableListUpdateAction<int>(
            insertAt: <int, Iterable<int>>{
              0: <int>[3, 4],
            },
          ),
        );
        expect(rxList.length, 5);
        expect(rxList.value, <int>[3, 4, 0, 1, 2]);

        controller.add(ObservableListUpdateAction<int>(removeAtPositions: <int>{0}));
        expect(rxList.length, 4);
        expect(rxList.value, <int>[4, 0, 1, 2]);

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
        expect(rxList.value, <int>[-1]);

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
        expect(rxList.value, <int>[0]);
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
        expect(rxList.value, <int>[0]);

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
        expect(rxList.value, <int>[0, 1, 2, 3]);
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
        expect(rxList.value, <int>[0, 1, 2, 3]);

        await listener.dispose();

        controller.add(ObservableListUpdateAction<int>(addItems: <int>[4]));
        controller.add(ObservableListUpdateAction<int>(addItems: <int>[5]));

        listener = rxList.listen();

        expect(rxList.length, 6);
        expect(rxList.value, <int>[0, 1, 2, 3, 4, 5]);
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
        expect(rxList.value, <int>[1, 2, 3, 4, 5, 4, 5, 6, 6, 6, 6]);

        source1.add(7);
        expect(source1.value, <int>[1, 2, 3, 4, 5, 7]);
        expect(rxList.length, 12);
        expect(rxList.value, <int>[1, 2, 3, 4, 5, 7, 4, 5, 6, 6, 6, 6]);

        source2.add(7);
        expect(source2.value, <int>[4, 5, 6, 7]);
        expect(rxList.length, 13);
        expect(rxList.value, <int>[1, 2, 3, 4, 5, 7, 4, 5, 6, 7, 6, 6, 6]);

        source1.removeAt(0);
        expect(source1.value, <int>[2, 3, 4, 5, 7]);
        expect(rxList.length, 12);
        expect(rxList.value, <int>[2, 3, 4, 5, 7, 4, 5, 6, 7, 6, 6, 6]);

        source2.removeAt(0);
        expect(source2.value, <int>[5, 6, 7]);
        expect(rxList.length, 11);
        expect(rxList.value, <int>[2, 3, 4, 5, 7, 5, 6, 7, 6, 6, 6]);

        source1[0] = 10;
        expect(source1.value, <int>[10, 3, 4, 5, 7]);
        expect(rxList.length, 11);
        expect(rxList.value, <int>[10, 3, 4, 5, 7, 5, 6, 7, 6, 6, 6]);

        source2[0] = 12;
        expect(source2.value, <int>[12, 6, 7]);
        expect(rxList.length, 11);
        expect(rxList.value, <int>[10, 3, 4, 5, 7, 12, 6, 7, 6, 6, 6]);
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
        expect(rxList.value, <int>[1, 2, 3, 4, 5]);

        source1.add(6);
        expect(rxList.length, 6);
        expect(rxList.value, <int>[1, 2, 3, 6, 4, 5]);

        source3.add(7);
        expect(rxList.length, 7);
        expect(rxList.value, <int>[1, 2, 3, 6, 4, 5, 7]);
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
        expect(rxList.value, <int>[1, 2, 3, 3, 4, 5, 5, 6, 7]);

        source1.add(8);
        expect(rxList.length, 10);
        expect(rxList.value, <int>[1, 2, 3, 8, 3, 4, 5, 5, 6, 7]);

        source2.remove(3);
        expect(rxList.length, 9);
        expect(rxList.value, <int>[1, 2, 3, 8, 4, 5, 5, 6, 7]);

        source3[0] = 9;
        expect(rxList.length, 9);
        expect(rxList.value, <int>[1, 2, 3, 8, 4, 5, 9, 6, 7]);
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

    group('value', () {
      test('Should return an unmodifiable list', () {
        final ObservableList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final List<int> value = rxList.value;
        expect(() => value.add(4), throwsUnsupportedError);
      });
    });

    group('listen', () {
      test('Should emit updated state', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final List<ObservableListChange<int>> changes = <ObservableListChange<int>>[];
        rxList.listen(
          onChange: (final List<int> state) {
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
        expect(rxSorted.value, <int>[10, 9, 8, 7, 6, 5, 4, 3, 2, 1]);
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
        expect(rxSorted.value, <int>[1]);
        expect(lastChange!.added[0], 1);

        rxSource.add(5);
        expect(rxSorted.length, 2);
        expect(rxSorted.value, <int>[5, 1]);
        expect(lastChange!.added[0], 5);

        rxSource.add(3);
        expect(rxSorted.length, 3);
        expect(rxSorted.value, <int>[5, 3, 1]);
        expect(lastChange!.added[1], 3);

        rxSource.add(7);
        expect(rxSource.value, <int>[1, 5, 3, 7]);
        expect(rxSorted.length, 4);
        expect(rxSorted.value, <int>[7, 5, 3, 1]);
        expect(lastChange!.added[0], 7);

        rxSource.insert(0, 2);
        expect(rxSource.value, <int>[2, 1, 5, 3, 7]);
        expect(rxSorted.length, 5);
        expect(rxSorted.value, <int>[7, 5, 3, 2, 1]);
        expect(lastChange!.added[3], 2);

        rxSource.removeAt(0);
        expect(rxSource.value, <int>[1, 5, 3, 7]);
        expect(rxSorted.length, 4);
        expect(rxSorted.value, <int>[7, 5, 3, 1]);
        expect(lastChange!.removed[3], 2);

        rxSource[2] = 10;
        expect(rxSource.value, <int>[1, 5, 10, 7]);
        expect(rxSorted.length, 4);
        expect(rxSorted.value, <int>[10, 7, 5, 1]);
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
        expect(filteredList.value, <int>[2, 4, 6, 8, 10]);
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
        expect(filteredList.value, <int>[2, 4, 6, 8, 10]);
        expect(changes[0].added.length, 5);

        rxSource.add(11);
        expect(rxSource.value, <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
        expect(filteredList.length, 5);
        expect(filteredList.value, <int>[2, 4, 6, 8, 10]);

        rxSource.add(12);
        expect(rxSource.value, <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 6);
        expect(filteredList.value, <int>[2, 4, 6, 8, 10, 12]);
        expect(changes[1].added[5], 12);

        rxSource.removeAt(0);
        expect(rxSource.value, <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 6);
        expect(filteredList.value, <int>[2, 4, 6, 8, 10, 12]);
        expect(changes.length, 2);

        rxSource.removeAt(0);
        expect(rxSource.value, <int>[3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 5);
        expect(filteredList.value, <int>[4, 6, 8, 10, 12]);
        expect(changes[2].removed[0], 2);

        rxSource[1] = 20;
        expect(rxSource.value, <int>[3, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.length, 5);
        expect(filteredList.value, <int>[20, 6, 8, 10, 12]);
        expect(changes[3].updated[0]!.oldValue, 4);
        expect(changes[3].updated[0]!.newValue, 20);

        rxSource.insertAll(2, <int>[20, 20, 20, 20, 20]);
        expect(rxSource.value, <int>[3, 20, 20, 20, 20, 20, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.value, <int>[20, 20, 20, 20, 20, 20, 6, 8, 10, 12]);
        expect(changes.length, 5);

        rxSource[3] = 3;
        expect(rxSource.value, <int>[3, 20, 20, 3, 20, 20, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.value, <int>[20, 20, 20, 20, 20, 6, 8, 10, 12]);
        expect(changes.length, 6);
        expect(changes[5].removed[2], 20);

        rxSource[3] = 10;
        expect(rxSource.value, <int>[3, 20, 20, 10, 20, 20, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.value, <int>[20, 20, 10, 20, 20, 20, 6, 8, 10, 12]);
        expect(changes.length, 7);
        expect(changes[6].added[2], 10);

        rxSource.removeAt(0);
        expect(rxSource.value, <int>[20, 20, 10, 20, 20, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.value, <int>[20, 20, 10, 20, 20, 20, 6, 8, 10, 12]);
        expect(changes.length, 7);

        rxSource.removeAt(0);
        expect(rxSource.value, <int>[20, 10, 20, 20, 20, 5, 6, 7, 8, 9, 10, 11, 12]);
        expect(filteredList.value, <int>[20, 10, 20, 20, 20, 6, 8, 10, 12]);
        expect(changes.length, 8);
        expect(changes[7].removed[0], 20);
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
        expect(rxMapped.value, <String>['1', '2', '3', '4', '5']);
      });

      test('Should map changes', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value, <String>['1', '2', '3', '4', '5']);

        rxSource.add(6);

        expect(rxMapped.length, 6);
        expect(rxMapped.value, <String>['1', '2', '3', '4', '5', '6']);

        rxSource.removeAt(0);

        expect(rxMapped.length, 5);
        expect(rxMapped.value, <String>['2', '3', '4', '5', '6']);

        rxSource[0] = 7;

        expect(rxMapped.length, 5);
        expect(rxMapped.value, <String>['7', '3', '4', '5', '6']);
      });

      test('Should dispose when source disposed', () async {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value, <String>['1', '2', '3', '4', '5']);

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
          (final List<int> state) {
            final int mod = state.length % 3;
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
          (final List<int> state) {
            final int mod = state.length % 3;
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
          final Rx<int> rxSource = Rx<int>(0);
          final ObservableMap<int, String> rxSwitched = rxSource.switchMapAs.map<int, String>(
            mapper: (final int value) {
              final int mod = value % 3;
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
          expect(rxSwitched.value, <int, String>{1: '1'});

          rxType1[1] = '4';
          expect(rxSwitched.value, <int, String>{1: '4'});
          rxType1[2] = '5';
          expect(rxSwitched.value, <int, String>{1: '4', 2: '5'});

          rxSource.value = 1;
          expect(rxSwitched.length, 1);
          expect(rxSwitched.value, <int, String>{2: '2'});

          rxSource.value = 0;
          expect(rxSwitched.length, 2);
          expect(rxSwitched.value, <int, String>{1: '4', 2: '5'});

          rxSource.value = 2;
          expect(rxSwitched.length, 1);
          expect(rxSwitched.value, <int, String>{3: '3'});

          await rxSource.dispose();
          expect(rxSwitched.disposed, true);
        });
      });
    });

    group('transformAs', () {
      group('list', () {
        test('Should transform the text into characters', () {
          final Rx<String> rxSource = Rx<String>('Hello World');
          final ObservableList<String> rxTransformed = rxSource.transformAs.list<String>(
            transform: (
              final ObservableList<String> state,
              final String value,
              final Emitter<List<String>> emitter,
            ) {
              emitter(<String>[for (final String char in value.split('')) char]);
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 11);
          expect(rxTransformed.value, <String>['H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd']);

          rxSource.value = 'Update';
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>['U', 'p', 'd', 'a', 't', 'e']);
        });

        test('Should transform to a new list', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          final ObservableList<String> rxTransformed = rxSource.transformAs.list<String>(
            transform: (
              final ObservableList<String> state,
              final List<int> value,
              final Emitter<List<String>> emitter,
            ) {
              emitter(<String>[for (final int item in value) item.toString()]);
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>['1', '2', '3', '4', '5']);

          rxSource.add(6);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>['1', '2', '3', '4', '5', '6']);

          rxSource.removeAt(0);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>['2', '3', '4', '5', '6']);

          rxSource[0] = 7;
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>['7', '3', '4', '5', '6']);

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform to a new list', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          final ObservableStatefulList<String, String> rxTransformed =
              rxSource.transformAs.statefulList<String, String>(
            transform: (
              final ObservableStatefulList<String, String> state,
              final List<int> value,
              final Emitter<Either<List<String>, String>> emitter,
            ) {
              if (value.contains(0)) {
                emitter(Either<List<String>, String>.right('0'));
              } else {
                emitter(Either<List<String>, String>.left(<String>[for (final int item in value) item.toString()]));
              }
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>['1', '2', '3', '4', '5']);

          rxSource.add(6);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>['1', '2', '3', '4', '5', '6']);

          rxSource.removeAt(0);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>['2', '3', '4', '5', '6']);

          rxSource[0] = 7;
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>['7', '3', '4', '5', '6']);

          rxSource.add(0);
          expect(rxTransformed.length, null);
          expect(rxTransformed.value.leftOrNull, null);
          expect(rxTransformed.value.rightOrThrow, '0');

          rxSource.remove(0);

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>['7', '3', '4', '5', '6']);
          expect(rxTransformed.value.rightOrNull, null);

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('map', () {
        test('Should transform to a new map', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          final ObservableMap<int, String> rxTransformed = rxSource.transformAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> state,
              final List<int> value,
              final Emitter<Map<int, String>> emitter,
            ) {
              emitter(<int, String>{for (final int item in value) item: item.toString()});
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <int, String>{1: '1', 2: '2', 3: '3', 4: '4', 5: '5'});

          rxSource.add(6);
          expect(rxSource.value, <int>[1, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <int, String>{1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6'});

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <int, String>{2: '2', 3: '3', 4: '4', 5: '5', 6: '6'});

          rxSource[0] = 7;
          expect(rxSource.value, <int>[7, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <int, String>{3: '3', 4: '4', 5: '5', 6: '6', 7: '7'});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform to a new map', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          final ObservableStatefulMap<int, String, String> rxTransformed =
              rxSource.transformAs.statefulMap<int, String, String>(
            transform: (
              final ObservableStatefulMap<int, String, String> state,
              final List<int> value,
              final Emitter<Either<Map<int, String>, String>> emitter,
            ) {
              if (value.contains(0)) {
                emitter(Either<Map<int, String>, String>.right('0'));
              } else {
                emitter(
                  Either<Map<int, String>, String>.left(
                    <int, String>{for (final int item in value) item: item.toString()},
                  ),
                );
              }
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <int, String>{1: '1', 2: '2', 3: '3', 4: '4', 5: '5'});

          rxSource.add(6);
          expect(rxSource.value, <int>[1, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <int, String>{1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6'});

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <int, String>{2: '2', 3: '3', 4: '4', 5: '5', 6: '6'});

          rxSource[0] = 7;
          expect(rxSource.value, <int>[7, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <int, String>{3: '3', 4: '4', 5: '5', 6: '6', 7: '7'});

          rxSource.add(0);
          expect(rxSource.value, <int>[7, 3, 4, 5, 6, 0]);
          expect(rxTransformed.length, null);
          expect(rxTransformed.value.leftOrNull, null);
          expect(rxTransformed.value.rightOrThrow, '0');

          rxSource.remove(0);
          expect(rxSource.value, <int>[7, 3, 4, 5, 6]);

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <int, String>{3: '3', 4: '4', 5: '5', 6: '6', 7: '7'});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('set', () {
        test('Should transform to a new set', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          final ObservableSet<String> rxTransformed = rxSource.transformAs.set<String>(
            transform: (
              final ObservableSet<String> state,
              final List<int> value,
              final Emitter<Set<String>> emitter,
            ) {
              emitter(<String>{for (final int item in value) item.toString()});
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>{'1', '2', '3', '4', '5'});

          rxSource.add(6);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>{'1', '2', '3', '4', '5', '6'});

          rxSource.removeAt(0);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>{'2', '3', '4', '5', '6'});

          rxSource[0] = 7;
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>{'7', '3', '4', '5', '6'});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Should transform to a new set', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          final ObservableStatefulSet<String, String> rxTransformed = rxSource.transformAs.statefulSet<String, String>(
            transform: (
              final ObservableStatefulSet<String, String> state,
              final List<int> value,
              final Emitter<Either<Set<String>, String>> emitter,
            ) {
              if (value.contains(0)) {
                emitter(Either<Set<String>, String>.right('0'));
              } else {
                emitter(Either<Set<String>, String>.left(<String>{for (final int item in value) item.toString()}));
              }
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>{'1', '2', '3', '4', '5'});

          rxSource.add(6);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>{'1', '2', '3', '4', '5', '6'});

          rxSource.removeAt(0);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>{'2', '3', '4', '5', '6'});

          rxSource[0] = 7;
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>{'7', '3', '4', '5', '6'});

          rxSource.add(0);
          expect(rxTransformed.length, null);
          expect(rxTransformed.value.leftOrNull, null);
          expect(rxTransformed.value.rightOrThrow, '0');

          rxSource.remove(0);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>{'7', '3', '4', '5', '6'});
          expect(rxTransformed.value.rightOrNull, null);

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });
    });

    group('transformChangeAs', () {
      group('list', () {
        test('Should transform the change as a new list', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          rxSource.add(6);

          final ObservableList<String> rxTransformed = rxSource.transformChangeAs.list<String>(
            transform: (
              final ObservableList<String> current,
              final List<int> state,
              final ObservableListChange<int> change,
              final Emitter<ObservableListUpdateAction<String>> emitter,
            ) {
              final Map<int, int> added = change.added;
              final Map<int, int> removed = change.removed;
              final Map<int, ObservableItemChange<int>> updated = change.updated;

              String mapper(final int value) => 'E${value * 2}';

              emitter(
                ObservableListUpdateAction<String>(
                  insertAt: <int, List<String>>{
                    for (final MapEntry<int, int> entry in added.entries) entry.key: <String>[mapper(entry.value)],
                  },
                  removeAtPositions: removed.keys.toSet(),
                  updateItems: <int, String>{
                    for (final MapEntry<int, ObservableItemChange<int>> entry in updated.entries)
                      entry.key: mapper(entry.value.newValue),
                  },
                ),
              );
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>['E2', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>['E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.insert(0, 7);
          expect(rxSource.value, <int>[7, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>['E14', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource[0] = 8;
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>['E16', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.clear();
          expect(rxSource.value, <int>[]);
          expect(rxTransformed.length, 0);
          expect(rxTransformed.value, <String>[]);

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('statefulList', () {
        test('Should transform the change as a new list', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          rxSource.add(6);

          final ObservableStatefulList<String, String> rxTransformed =
              rxSource.transformChangeAs.statefulList<String, String>(
            transform: (
              final ObservableStatefulList<String, String> current,
              final List<int> state,
              final ObservableListChange<int> change,
              final Emitter<Either<ObservableListUpdateAction<String>, String>> emitter,
            ) {
              final Map<int, int> added = change.added;
              final Map<int, int> removed = change.removed;
              final Map<int, ObservableItemChange<int>> updated = change.updated;

              String mapper(final int value) => 'E${value * 2}';

              if (added.containsValue(-1)) {
                emitter(Either<ObservableListUpdateAction<String>, String>.right('empty'));
                return;
              }

              if (removed.containsValue(-1)) {
                // re-add items
                emitter(
                  Either<ObservableListUpdateAction<String>, String>.left(
                    ObservableListUpdateAction<String>(
                      addItems: <String>[for (final int item in state) mapper(item)],
                    ),
                  ),
                );
                return;
              }

              emitter(
                Either<ObservableListUpdateAction<String>, String>.left(
                  ObservableListUpdateAction<String>(
                    insertAt: <int, List<String>>{
                      for (final MapEntry<int, int> entry in added.entries) entry.key: <String>[mapper(entry.value)],
                    },
                    removeAtPositions: removed.keys.toSet(),
                    updateItems: <int, String>{
                      for (final MapEntry<int, ObservableItemChange<int>> entry in updated.entries)
                        entry.key: mapper(entry.value.newValue),
                    },
                  ),
                ),
              );
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>['E2', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>['E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.insert(0, 7);
          expect(rxSource.value, <int>[7, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>['E14', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource[0] = 8;
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>['E16', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.add(-1);
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6, -1]);
          expect(rxTransformed.length, null);
          expect(rxTransformed.value.leftOrNull, null);
          expect(rxTransformed.value.rightOrThrow, 'empty');

          rxSource.remove(-1);
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>['E16', 'E4', 'E6', 'E8', 'E10', 'E12']);

          rxSource.clear();
          expect(rxSource.value, <int>[]);
          expect(rxTransformed.length, 0);
          expect(rxTransformed.value.leftOrThrow, <String>[]);

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('map', () {
        test('Should transform the change as a new map', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          rxSource.add(6);

          final ObservableMap<int, String> rxTransformed = rxSource.transformChangeAs.map<int, String>(
            transform: (
              final ObservableMap<int, String> current,
              final List<int> state,
              final ObservableListChange<int> change,
              final Emitter<ObservableMapUpdateAction<int, String>> emitter,
            ) {
              final Map<int, int> added = change.added;
              final Map<int, int> removed = change.removed;
              final Map<int, ObservableItemChange<int>> updated = change.updated;

              String mapper(final int value) => 'E${value * 2}';

              emitter(
                ObservableMapUpdateAction<int, String>(
                  addItems: <int, String>{
                    for (final MapEntry<int, int> entry in added.entries) entry.value: mapper(entry.value),
                    for (final MapEntry<int, ObservableItemChange<int>> entry in updated.entries)
                      entry.value.newValue: mapper(entry.value.newValue),
                  },
                  removeKeys: <int>{
                    ...removed.values.toSet(),
                    ...updated.values.map((final ObservableItemChange<int> change) => change.oldValue).toSet(),
                  },
                ),
              );
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <int, String>{1: 'E2', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <int, String>{2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          rxSource.insert(0, 7);
          expect(rxSource.value, <int>[7, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <int, String>{7: 'E14', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          rxSource[0] = 8;
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <int, String>{8: 'E16', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('statefulMap', () {
        test('Should transform the change as a new map', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          rxSource.add(6);

          final ObservableStatefulMap<int, String, String> rxTransformed =
              rxSource.transformChangeAs.statefulMap<int, String, String>(
            transform: (
              final ObservableStatefulMap<int, String, String> current,
              final List<int> state,
              final ObservableListChange<int> change,
              final Emitter<Either<ObservableMapUpdateAction<int, String>, String>> emitter,
            ) {
              final Map<int, int> added = change.added;
              final Map<int, int> removed = change.removed;
              final Map<int, ObservableItemChange<int>> updated = change.updated;

              String mapper(final int value) => 'E${value * 2}';

              if (added.containsValue(-1)) {
                emitter(Either<ObservableMapUpdateAction<int, String>, String>.right('empty'));
                return;
              }

              if (removed.containsValue(-1)) {
                // re-add items
                emitter(
                  Either<ObservableMapUpdateAction<int, String>, String>.left(
                    ObservableMapUpdateAction<int, String>(
                      addItems: <int, String>{
                        for (final int item in state) item: mapper(item),
                      },
                    ),
                  ),
                );
                return;
              }

              emitter(
                Either<ObservableMapUpdateAction<int, String>, String>.left(
                  ObservableMapUpdateAction<int, String>(
                    addItems: <int, String>{
                      for (final MapEntry<int, int> entry in added.entries) entry.value: mapper(entry.value),
                      for (final MapEntry<int, ObservableItemChange<int>> entry in updated.entries)
                        entry.value.newValue: mapper(entry.value.newValue),
                    },
                    removeKeys: <int>{
                      ...removed.values.toSet(),
                      ...updated.values.map((final ObservableItemChange<int> change) => change.oldValue).toSet(),
                    },
                  ),
                ),
              );
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 6);
          expect(
            rxTransformed.value.leftOrThrow,
            <int, String>{1: 'E2', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'},
          );

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <int, String>{2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'});

          rxSource.insert(0, 7);
          expect(rxSource.value, <int>[7, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(
            rxTransformed.value.leftOrThrow,
            <int, String>{7: 'E14', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'},
          );

          rxSource[0] = 8;
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(
            rxTransformed.value.leftOrThrow,
            <int, String>{8: 'E16', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'},
          );

          rxSource.add(-1);
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6, -1]);
          expect(rxTransformed.length, null);
          expect(rxTransformed.value.leftOrNull, null);
          expect(rxTransformed.value.rightOrThrow, 'empty');

          rxSource.remove(-1);
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(
            rxTransformed.value.leftOrThrow,
            <int, String>{8: 'E16', 2: 'E4', 3: 'E6', 4: 'E8', 5: 'E10', 6: 'E12'},
          );

          rxSource.clear();
          expect(rxSource.value, <int>[]);
          expect(rxTransformed.length, 0);
          expect(rxTransformed.value.leftOrThrow, <int, String>{});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('set', () {
        test('Should transform the change as a new set', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          rxSource.add(6);

          final ObservableSet<String> rxTransformed = rxSource.transformChangeAs.set<String>(
            transform: (
              final ObservableSet<String> current,
              final List<int> state,
              final ObservableListChange<int> change,
              final Emitter<ObservableSetUpdateAction<String>> emitter,
            ) {
              final Map<int, int> added = change.added;
              final Map<int, int> removed = change.removed;
              final Map<int, ObservableItemChange<int>> updated = change.updated;

              String mapper(final int value) => 'E${value * 2}';

              emitter(
                ObservableSetUpdateAction<String>(
                  addItems: <String>{
                    for (final MapEntry<int, int> entry in added.entries) mapper(entry.value),
                    for (final MapEntry<int, ObservableItemChange<int>> entry in updated.entries)
                      mapper(entry.value.newValue),
                  },
                  removeItems: <String>{
                    for (final int value in removed.values) mapper(value),
                    for (final ObservableItemChange<int> change in updated.values) mapper(change.oldValue),
                  },
                ),
              );
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>{'E2', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value, <String>{'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource.insert(0, 7);
          expect(rxSource.value, <int>[7, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>{'E14', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource[0] = 8;
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value, <String>{'E16', 'E4', 'E6', 'E8', 'E10', 'E12'});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
        });
      });

      group('statefulSet', () {
        test('Should transform the change as a new set', () async {
          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
          rxSource.add(6);

          final ObservableStatefulSet<String, String> rxTransformed =
              rxSource.transformChangeAs.statefulSet<String, String>(
            transform: (
              final ObservableStatefulSet<String, String> current,
              final List<int> state,
              final ObservableListChange<int> change,
              final Emitter<Either<ObservableSetUpdateAction<String>, String>> emitter,
            ) {
              final Map<int, int> added = change.added;
              final Map<int, int> removed = change.removed;
              final Map<int, ObservableItemChange<int>> updated = change.updated;

              String mapper(final int value) => 'E${value * 2}';

              if (added.containsValue(-1)) {
                emitter(Either<ObservableSetUpdateAction<String>, String>.right('empty'));
                return;
              }

              if (removed.containsValue(-1)) {
                // re-add items
                emitter(
                  Either<ObservableSetUpdateAction<String>, String>.left(
                    ObservableSetUpdateAction<String>(
                      addItems: <String>{for (final int item in state) mapper(item)},
                    ),
                  ),
                );
                return;
              }

              emitter(
                Either<ObservableSetUpdateAction<String>, String>.left(
                  ObservableSetUpdateAction<String>(
                    addItems: <String>{
                      for (final MapEntry<int, int> entry in added.entries) mapper(entry.value),
                      for (final MapEntry<int, ObservableItemChange<int>> entry in updated.entries)
                        mapper(entry.value.newValue),
                    },
                    removeItems: <String>{
                      ...removed.values.map((final int value) => mapper(value)).toSet(),
                      ...updated.values
                          .map((final ObservableItemChange<int> change) => mapper(change.oldValue))
                          .toSet(),
                    },
                  ),
                ),
              );
            },
          );

          rxTransformed.listen();

          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>{'E2', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource.removeAt(0);
          expect(rxSource.value, <int>[2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 5);
          expect(rxTransformed.value.leftOrThrow, <String>{'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource.insert(0, 7);
          expect(rxSource.value, <int>[7, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>{'E14', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource[0] = 8;
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>{'E16', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource.add(-1);
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6, -1]);
          expect(rxTransformed.length, null);
          expect(rxTransformed.value.leftOrNull, null);
          expect(rxTransformed.value.rightOrThrow, 'empty');

          rxSource.remove(-1);
          expect(rxSource.value, <int>[8, 2, 3, 4, 5, 6]);
          expect(rxTransformed.length, 6);
          expect(rxTransformed.value.leftOrThrow, <String>{'E16', 'E4', 'E6', 'E8', 'E10', 'E12'});

          rxSource.clear();
          expect(rxSource.value, <int>[]);
          expect(rxTransformed.length, 0);
          expect(rxTransformed.value.leftOrThrow, <String>{});

          await rxSource.dispose();
          expect(rxTransformed.disposed, true);
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

        expect(rxResult.value.length, 2);
      });
    });
  });
}
