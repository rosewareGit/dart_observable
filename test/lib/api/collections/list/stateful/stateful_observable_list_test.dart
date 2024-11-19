import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableStatefulList', () {
    group('just', () {
      test('should create a new instance with the given data', () {
        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.just(<int>[1, 2, 3]);
        expect(list.value.leftOrThrow.listView, <int>[1, 2, 3]);
      });
    });

    group('custom', () {
      test('should create a new instance with the given custom state', () {
        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.custom('custom');
        expect(list.value.leftOrNull, null);
        expect(list.value.rightOrThrow, 'custom');
      });
    });

    group('merged', () {
      test('should create a new instance with the given collections', () {
        final RxStatefulList<int, String> list1 = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        final RxStatefulList<int, String> list2 = RxStatefulList<int, String>(initial: <int>[4, 5, 6]);

        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.merged(
          collections: <ObservableStatefulList<int, String>>[
            list1,
            list2,
          ],
        );

        list.listen();

        expect(list.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5, 6]);
      });

      test('Should update the merged list when the source list changes without a custom state handler', () async {
        final RxStatefulList<int, String> list1 = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        final RxStatefulList<int, String> list2 = RxStatefulList<int, String>(initial: <int>[4, 5, 6]);

        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.merged(
          collections: <ObservableStatefulList<int, String>>[
            list1,
            list2,
          ],
        );

        list.listen();

        expect(list.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5, 6]);

        list1.add(7);
        expect(list.value.leftOrThrow.listView, <int>[1, 2, 3, 7, 4, 5, 6]);

        list2.add(8);
        expect(list.value.leftOrThrow.listView, <int>[1, 2, 3, 7, 4, 5, 6, 8]);

        // test updates in source lists
        list1[0] = 10;
        expect(list.value.leftOrThrow.listView, <int>[10, 2, 3, 7, 4, 5, 6, 8]);
        list1[2] = 12;
        expect(list.value.leftOrThrow.listView, <int>[10, 2, 12, 7, 4, 5, 6, 8]);

        list1.setState('custom');
        expect(list.value.leftOrThrow.listView, <int>[4, 5, 6, 8]);
        expect(list.value.rightOrNull, null);

        await list1.dispose();
        await list2.dispose();

        expect(list.disposed, true);
      });

      test('Should update state when custom handler is set', () {
        final RxStatefulList<int, String> list1 = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        final RxStatefulList<int, String> list2 = RxStatefulList<int, String>(initial: <int>[4, 5, 6]);

        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.merged(
          collections: <ObservableStatefulList<int, String>>[list1, list2],
          stateResolver: (final String state) => Either<List<int>, String>.right(state),
        );

        list.listen();

        expect(list.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5, 6]);

        list1.setState('custom');
        expect(list.value.leftOrNull, null);
        expect(list.value.rightOrThrow, 'custom');

        list2.setState('custom2');
        expect(list.value.leftOrNull, null);
        expect(list.value.rightOrThrow, 'custom2');

        list1.add(0);
        expect(list.value.leftOrThrow.listView, <int>[0]);

        list2.add(0);
        expect(list.value.leftOrThrow.listView, <int>[0, 0]);

        list1[0] = 1;
        expect(list.value.leftOrThrow.listView, <int>[1, 0]);
      });
    });

    group('fromStream', () {
      test('should create a new instance with the given stream', () {
        final Stream<Either<ObservableListUpdateAction<int>, String>> stream =
            Stream<Either<ObservableListUpdateAction<int>, String>>.empty();
        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.fromStream(stream: stream);
        expect(list.value.leftOrNull!.listView, <int>[]);
        expect(list.value.rightOrNull, null);
      });

      test('Should update from the stream', () async {
        final StreamController<Either<ObservableListUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableListUpdateAction<int>, String>>(sync: true);
        final ObservableStatefulList<int, String> list =
            ObservableStatefulList<int, String>.fromStream(stream: controller.stream);

        list.listen();

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(ObservableListUpdateAction<int>(addItems: <int>[0, 1])),
        );
        expect(list.value.leftOrThrow.listView, <int>[0, 1]);

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(
            ObservableListUpdateAction<int>(
              insertAt: <int, Iterable<int>>{
                0: <int>[1],
              },
            ),
          ),
        );
        expect(list.value.leftOrThrow.listView, <int>[1, 0, 1]);

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(
            ObservableListUpdateAction<int>(
              updateItems: <int, int>{
                0: 2,
              },
            ),
          ),
        );
        expect(list.value.leftOrThrow.listView, <int>[2, 0, 1]);

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(ObservableListUpdateAction<int>(removeItems: <int>{1})),
        );
        expect(list.value.leftOrThrow.listView, <int>[2, 1]);

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.right('custom'),
        );
        expect(list.value.leftOrNull, null);
        expect(list.value.rightOrThrow, 'custom');

        await controller.close();
        expect(list.disposed, true);
      });

      test('Should handle errors from the stream', () {
        final StreamController<Either<ObservableListUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableListUpdateAction<int>, String>>(sync: true);
        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.fromStream(
          stream: controller.stream,
          onError: (final dynamic error) => Either<List<int>, String>.left(<int>[99]),
        );

        list.listen();

        controller.addError(Exception('Test error'));

        expect(list.value.leftOrThrow.listView, <int>[99]);
      });

      test('Should handle custom state from the stream', () {
        final StreamController<Either<ObservableListUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableListUpdateAction<int>, String>>(sync: true);
        final ObservableStatefulList<int, String> list =
            ObservableStatefulList<int, String>.fromStream(stream: controller.stream);

        list.listen();

        controller.add(Either<ObservableListUpdateAction<int>, String>.right('custom state'));

        expect(list.value.leftOrNull, null);
        expect(list.value.rightOrThrow, 'custom state');
      });

      test('Should update the list with all the pending changes after listening', () async {
        final StreamController<Either<ObservableListUpdateAction<int>, String>> controller =
            StreamController<Either<ObservableListUpdateAction<int>, String>>(sync: true);
        final ObservableStatefulList<int, String> list = ObservableStatefulList<int, String>.fromStream(
          stream: controller.stream,
        );

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(ObservableListUpdateAction<int>(addItems: <int>[0, 1])),
        );
        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(
            ObservableListUpdateAction<int>(
              insertAt: <int, Iterable<int>>{
                0: <int>[1],
              },
            ),
          ),
        );
        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(
            ObservableListUpdateAction<int>(
              updateItems: <int, int>{
                0: 2,
              },
            ),
          ),
        );
        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(ObservableListUpdateAction<int>(removeItems: <int>{1})),
        );

        Disposable listener = list.listen();

        expect(list.value.leftOrThrow.listView, <int>[2, 1]);

        await listener.dispose();

        controller.add(
          Either<ObservableListUpdateAction<int>, String>.left(ObservableListUpdateAction<int>(addItems: <int>[3, 4])),
        );

        listener = list.listen();

        expect(list.value.leftOrThrow.listView, <int>[2, 1, 3, 4]);
      });
    });

    group('length', () {
      test('should return the length of the list', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        expect(list.length, 3);

        list.add(4);
        expect(list.length, 4);

        list.setState('custom');
        expect(list.length, null);
      });
    });

    group('[]', () {
      test('should return the item at the given index', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        expect(list[0], 1);
        expect(list[1], 2);
        expect(list[2], 3);

        list.add(4);
        expect(list[3], 4);

        list.setState('custom');
        expect(list[0], null);
        expect(list[1], null);
        expect(list[2], null);
        expect(list[3], null);
      });
    });

    group('filterItem', () {
      test('Should filter initial list', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<int, String> rxFiltered = rxList.filterItem((final int item) => item.isOdd);

        rxFiltered.listen();
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5]);
      });

      test('should filter the items of the list', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<int, String> rxFiltered = rxList.filterItem((final int item) => item.isOdd);

        Either<ObservableListChange<int>, String>? lastChange;
        rxFiltered.onChange(
          onChange: (final Either<ObservableListChange<int>, String> change) {
            lastChange = change;
          },
        );

        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 1, 1: 3, 2: 5});

        rxList.add(6);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 1, 1: 3, 2: 5}, reason: 'No changes, still the same');

        rxList.add(7);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5, 7]);
        expect(lastChange!.leftOrThrow.added, <int, int>{3: 7});

        rxList.remove(3);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 5, 7]);
        expect(lastChange!.leftOrThrow.removed, <int, int>{1: 3});

        rxList.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxList.add(8);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[]);
        expect(lastChange!.leftOrThrow.added, <int, int>{});

        rxList.setState('custom');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'custom');

        rxList.add(9);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[9]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 9});

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[9, 11]);
        expect(lastChange!.leftOrThrow.added, <int, int>{1: 11});

        rxList.clear();
        expect(rxFiltered.value.leftOrThrow.listView, <int>[]);
        expect(lastChange!.leftOrThrow.removed, <int, int>{0: 9, 1: 11});

        await rxList.dispose();

        expect(rxFiltered.disposed, true);
      });
    });

    group('filterItemWithState', () {
      test('Should filter initial list', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<int, String> rxSorted =
            rxList.filterItemWithState((final Either<int, String> item) {
          return item.fold(
            onLeft: (final int item) => item.isOdd,
            onRight: (final String state) => true,
          );
        });

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 3, 5]);
      });

      test('Should be empty list when every item is filtered out', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<int, String> rxSorted =
            rxList.filterItemWithState((final Either<int, String> item) {
          return item.fold(
            onLeft: (final int item) => item > 10,
            onRight: (final String state) => false,
          );
        });

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.listView, <int>[]);
      });

      test('Should filter initial custom state', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(custom: 'custom');
        final ObservableStatefulList<int, String> rxSorted =
            rxList.filterItemWithState((final Either<int, String> item) {
          return item.fold(
            onLeft: (final int item) => item.isOdd,
            onRight: (final String state) => state.contains('st'),
          );
        });

        rxSorted.listen();
        expect(rxSorted.value.leftOrNull, null);
        expect(rxSorted.value.rightOrThrow, 'custom');
      });

      test('Should be empty list when initial state is filtered out', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(custom: 'custom');
        final ObservableStatefulList<int, String> rxSorted =
            rxList.filterItemWithState((final Either<int, String> item) {
          return item.fold(
            onLeft: (final int item) => item.isOdd,
            onRight: (final String state) => state.contains('TEST'),
          );
        });

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.listView, <int>[]);
      });

      test('should filter the items of the list', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<int, String> rxFiltered = rxList.filterItemWithState((final Either<int, String> item) {
          return item.fold(
            onLeft: (final int item) => item.isOdd,
            onRight: (final String state) => state.contains('test'),
          );
        });

        Either<ObservableListChange<int>, String>? lastChange;
        rxFiltered.onChange(
          onChange: (final Either<ObservableListChange<int>, String> change) {
            lastChange = change;
          },
        );

        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 1, 1: 3, 2: 5});

        rxList.add(6);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 1, 1: 3, 2: 5}, reason: 'No changes, still the same');

        rxList.add(7);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 3, 5, 7]);
        expect(lastChange!.leftOrThrow.added, <int, int>{3: 7});

        rxList.remove(3);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 5, 7]);
        expect(lastChange!.leftOrThrow.removed, <int, int>{1: 3});

        rxList.setState('custom');
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 5, 7], reason: 'Change ignored');
        expect(rxFiltered.value.rightOrNull, null);
        expect(lastChange!.leftOrThrow.removed, <int, int>{1: 3});

        rxList.add(8);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[1, 5, 7], reason: 'Change ignored');
        expect(lastChange!.leftOrThrow.removed, <int, int>{1: 3});

        rxList.setState('test123');
        expect(rxFiltered.value.leftOrNull, null);
        expect(rxFiltered.value.rightOrThrow, 'test123');
        expect(lastChange!.rightOrThrow, 'test123');

        rxList.add(9);
        expect(rxFiltered.value.leftOrThrow.listView, <int>[9]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 9});

        await rxList.dispose();

        expect(rxFiltered.disposed, true);
      });
    });

    group('sorted', () {
      test('Should return the sorted list', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[5, 3, 1, 4, 2]);
        final ObservableStatefulList<int, String> rxSorted =
            rxList.sorted((final int a, final int b) => a.compareTo(b));

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5]);
      });

      test('Should set to custom when the source list is set to custom', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[5, 3, 1, 4, 2]);
        final ObservableStatefulList<int, String> rxSorted =
            rxList.sorted((final int a, final int b) => a.compareTo(b));

        rxSorted.listen();
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5]);

        rxList.setState('custom');
        expect(rxSorted.value.leftOrNull, null);
        expect(rxSorted.value.rightOrThrow, 'custom');
      });

      test('Should handle source updates', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[5, 3, 1, 4, 2]);
        final ObservableStatefulList<int, String> rxSorted =
            rxList.sorted((final int a, final int b) => a.compareTo(b));

        Either<ObservableListChange<int>, String>? lastChange;
        rxSorted.onChange(
          onChange: (final Either<ObservableListChange<int>, String> change) {
            lastChange = change;
          },
        );

        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 1, 1: 2, 2: 3, 3: 4, 4: 5});

        rxList.add(6);
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5, 6]);
        expect(lastChange!.leftOrThrow.added, <int, int>{5: 6});

        rxList.add(7);
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5, 6, 7]);
        expect(lastChange!.leftOrThrow.added, <int, int>{6: 7});

        rxList.remove(3);
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 4, 5, 6, 7]);
        expect(lastChange!.leftOrThrow.removed, <int, int>{2: 3});

        rxList.setState('custom');
        expect(rxSorted.value.leftOrNull, null);
        expect(rxSorted.value.rightOrThrow, 'custom');

        rxList.add(8);
        expect(rxSorted.value.leftOrThrow.listView, <int>[8]);
        expect(lastChange!.leftOrThrow.added, <int, int>{0: 8});

        rxList.add(9);
        expect(rxSorted.value.leftOrThrow.listView, <int>[8, 9]);
        expect(lastChange!.leftOrThrow.added, <int, int>{1: 9});

        rxList[1] = 1;
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 8]);
        expect(lastChange!.leftOrThrow.updated[1]!.oldValue, 9);
        expect(lastChange!.leftOrThrow.updated[1]!.newValue, 1);

        rxList.add(8);
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 8, 8]);
        expect(lastChange!.leftOrThrow.added, <int, int>{2: 8});

        rxList.add(8);
        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 8, 8, 8]);
        expect(lastChange!.leftOrThrow.added, <int, int>{3: 8});
      });

      test('Should dispose when source disposed', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[5, 3, 1, 4, 2]);
        final ObservableStatefulList<int, String> rxSorted =
            rxList.sorted((final int a, final int b) => a.compareTo(b));

        rxSorted.listen();

        expect(rxSorted.value.leftOrThrow.listView, <int>[1, 2, 3, 4, 5]);

        await rxList.dispose();

        expect(rxSorted.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item at the given index', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final Observable<Either<int?, String>> rxItem = rxList.rxItem(2);

        rxItem.listen();
        expect(rxItem.value.leftOrNull, 3);

        rxList.add(6);
        expect(rxItem.value.leftOrNull, 3);

        rxList.add(7);
        expect(rxItem.value.leftOrNull, 3);

        rxList.remove(3);
        expect(rxItem.value.leftOrNull, 4);

        rxList.removeAt(2);
        expect(rxItem.value.leftOrNull, 5);

        rxList[2] = 10;
        expect(rxItem.value.leftOrNull, 10);

        rxList.setState('custom');
        expect(rxItem.value.leftOrNull, null);
        expect(rxItem.value.rightOrNull, 'custom');

        rxList.add(8);
        expect(rxItem.value.leftOrNull, null);

        rxList.add(9);
        expect(rxItem.value.leftOrNull, null);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxItem.value.leftOrNull, 10);

        rxList.clear();
        expect(rxItem.value.leftOrNull, null);

        await rxList.dispose();

        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map initial state on listen', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<String, String> rxMapped = rxList.mapItem((final int item) => item.toString());

        rxMapped.listen();
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5']);
      });

      test('Should map data change', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<String, String> rxMapped = rxList.mapItem((final int item) => item.toString());

        Either<ObservableListChange<String>, String>? lastChange;
        rxMapped.onChange(
          onChange: (final Either<ObservableListChange<String>, String> change) {
            lastChange = change;
          },
        );
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5']);
        final Map<int, String> added = lastChange!.leftOrThrow.added;
        expect(added[0], '1');
        expect(added[1], '2');
        expect(added[2], '3');
        expect(added[3], '4');
        expect(added[4], '5');

        rxList.add(6);
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5', '6']);
        expect(lastChange!.leftOrThrow.added[5], '6');

        rxList.add(7);
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5', '6', '7']);
        expect(lastChange!.leftOrThrow.added[6], '7');

        rxList.remove(3);
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '4', '5', '6', '7']);
        expect(lastChange!.leftOrThrow.removed[2], '3');

        rxList.setState('custom');
        expect(rxMapped.value.leftOrNull, null);
        expect(rxMapped.value.rightOrNull, 'custom');
        expect(lastChange!.rightOrThrow, 'custom');

        rxList.add(8);
        expect(rxMapped.value.leftOrThrow.listView, <String>['8']);
        expect(lastChange!.leftOrThrow.added[0], '8');

        rxList.add(9);
        expect(rxMapped.value.leftOrThrow.listView, <String>['8', '9']);
        expect(lastChange!.leftOrThrow.added[1], '9');

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxMapped.value.leftOrThrow.listView, <String>['8', '9', '10', '11', '12']);
        final Map<int, String> addedAll = lastChange!.leftOrThrow.added;
        expect(addedAll[2], '10');
        expect(addedAll[3], '11');
        expect(addedAll[4], '12');

        rxList.removeAt(0);
        expect(rxMapped.value.leftOrThrow.listView, <String>['9', '10', '11', '12']);
        expect(lastChange!.leftOrThrow.removed[0], '8');

        rxList.remove(9);
        expect(rxMapped.value.leftOrThrow.listView, <String>['10', '11', '12']);
        expect(lastChange!.leftOrThrow.removed[0], '9');

        rxList.clear();
        expect(rxMapped.value.leftOrThrow.listView, <String>[]);
        expect(lastChange!.leftOrThrow.removed[0], '10');
        expect(lastChange!.leftOrThrow.removed[1], '11');
        expect(lastChange!.leftOrThrow.removed[2], '12');

        await rxList.dispose();

        expect(rxMapped.disposed, true);
      });
    });

    group('mapItemWithState', () {
      test('Should map initial data state on listen', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<String, String> rxMapped = rxList.mapItemWithState(
          mapper: (final int item) => item.toString(),
          stateMapper: (final String state) => state,
        );

        rxMapped.listen();
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5']);
      });

      test('Should map initial custom state on listen', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(custom: 'custom');
        final ObservableStatefulList<String, String> rxMapped = rxList.mapItemWithState(
          mapper: (final int item) => item.toString(),
          stateMapper: (final String state) => state.toUpperCase(),
        );

        rxMapped.listen();
        expect(rxMapped.value.rightOrThrow, 'CUSTOM');
      });

      test('Should map changes', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<String, String> rxMapped = rxList.mapItemWithState(
          mapper: (final int item) => item.toString(),
          stateMapper: (final String state) => state.toUpperCase(),
        );

        Either<ObservableListChange<String>, String>? lastChange;
        rxMapped.onChange(
          onChange: (final Either<ObservableListChange<String>, String> change) {
            lastChange = change;
          },
        );
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5']);
        final Map<int, String> added = lastChange!.leftOrThrow.added;
        expect(added[0], '1');
        expect(added[1], '2');
        expect(added[2], '3');
        expect(added[3], '4');
        expect(added[4], '5');

        rxList.add(6);
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5', '6']);
        expect(lastChange!.leftOrThrow.added[5], '6');

        rxList.add(7);
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5', '6', '7']);
        expect(lastChange!.leftOrThrow.added[6], '7');

        rxList.remove(3);
        expect(rxMapped.value.leftOrThrow.listView, <String>['1', '2', '4', '5', '6', '7']);
        expect(lastChange!.leftOrThrow.removed[2], '3');

        rxList.setState('custom');
        expect(rxMapped.value.leftOrNull, null);
        expect(rxMapped.value.rightOrNull, 'CUSTOM');
        expect(lastChange!.rightOrThrow, 'CUSTOM');

        rxList.add(8);
        expect(rxMapped.value.leftOrThrow.listView, <String>['8']);
        expect(lastChange!.leftOrThrow.added[0], '8');

        rxList.add(9);
        expect(rxMapped.value.leftOrThrow.listView, <String>['8', '9']);
        expect(lastChange!.leftOrThrow.added[1], '9');

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxMapped.value.leftOrThrow.listView, <String>['8', '9', '10', '11', '12']);
        final Map<int, String> addedAll = lastChange!.leftOrThrow.added;
        expect(addedAll[2], '10');
        expect(addedAll[3], '11');
        expect(addedAll[4], '12');

        rxList.removeAt(0);
        expect(rxMapped.value.leftOrThrow.listView, <String>['9', '10', '11', '12']);
        expect(lastChange!.leftOrThrow.removed[0], '8');

        rxList.remove(9);
        expect(rxMapped.value.leftOrThrow.listView, <String>['10', '11', '12']);
        expect(lastChange!.leftOrThrow.removed[0], '9');

        rxList.clear();
        expect(rxMapped.value.leftOrThrow.listView, <String>[]);
        expect(lastChange!.leftOrThrow.removed[0], '10');
        expect(lastChange!.leftOrThrow.removed[1], '11');
        expect(lastChange!.leftOrThrow.removed[2], '12');

        await rxList.dispose();

        expect(rxMapped.disposed, true);
      });
    });
  });
}
