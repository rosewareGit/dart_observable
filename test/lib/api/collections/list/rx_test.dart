import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxList', () {
    group('[]=', () {
      test('Should set the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList[0] = 4;
        expect(rxList[0], 4);
      });

      test('Should add the item if the index is greater than the length of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList[10] = 4;
        expect(rxList[3], 4);
      });
    });

    group('add', () {
      test('Should add the item to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.add(4);
        expect(change!.added[3], 4);
        expect(rxList[3], 4);
      });
    });

    group('addAll', () {
      test('Should add all items to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.addAll(<int>[4, 5]);
        expect(change!.added[3], 4);
        expect(change.added[4], 5);
        expect(rxList[3], 4);
        expect(rxList[4], 5);
      });
    });

    group('insert', () {
      test('Should insert the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.insert(1, 4);
        expect(change!.added[1], 4);
        expect(rxList[1], 4);
      });
    });

    group('insertAll', () {
      test('Should insert all items at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.insertAll(1, <int>[4, 5]);
        expect(change!.added[1], 4);
        expect(change.added[2], 5);
        expect(rxList[1], 4);
        expect(rxList[2], 5);
      });
    });

    group('remove', () {
      test('Should remove the item from the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.remove(2);
        expect(change!.removed[1], 2);
        expect(rxList[1], 3);
      });
    });

    group('removeAt', () {
      test('Should remove the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.removeAt(1);
        expect(change!.removed[1], 2);
        expect(rxList[1], 3);
      });
    });

    group('removeWhere', () {
      test('Should remove items that satisfy the predicate', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.removeWhere((final int item) => item % 2 == 0);
        expect(change!.removed[1], 2);
        expect(rxList[0], 1);
        expect(rxList[1], 3);
      });
    });

    group('applyAction', () {
      test('Should apply action that contains multiple type of updates', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3, 0]);
        final ObservableListChange<int>? change = rxList.applyAction(
          ObservableListUpdateAction<int>(
            insertItemAtPosition: <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(0, <int>[4, 5]),
              MapEntry<int?, Iterable<int>>(1, <int>[6, 7]),
              MapEntry<int?, Iterable<int>>(null, <int>[11]),
              MapEntry<int?, Iterable<int>>(10, <int>[10]),
            ],
            removeIndexes: <int>{0, 1},
            updateItemAtPosition: <int, int>{
              2: 8,
            },
          ),
        );

        expect(rxList.value.listView, <int>[4, 5, 8, 6, 7, 0, 11, 10]);

        expect(change!.added[0], 4);
        expect(change.added[1], 5);
        expect(change.added[3], 6);
        expect(change.added[4], 7);
        expect(change.added[6], 11);
        expect(change.added[7], 10);
        expect(change.removed[0], 1);
        expect(change.removed[1], 2);
        expect(change.updated[2]!.newValue, 8);
      });

      test('Should not do anything if add action is empty', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.applyAction(
          ObservableListUpdateAction<int>.add(<MapEntry<int?, Iterable<int>>>[]),
        );

        expect(change, null);
      });

      test('Should not do anything if remove action is empty', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.applyAction(
          ObservableListUpdateAction<int>.remove(<int>{}),
        );

        expect(change, null);
      });

      test('Should not do anything if update action is empty', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.applyAction(
          ObservableListUpdateAction<int>.update(<int, int>{}),
        );

        expect(change, null);
      });

      test('Should apply add action to the list based on the added items-1', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.applyAction(
          ObservableListUpdateAction<int>.add(
            <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(0, <int>[4, 5]),
              MapEntry<int?, Iterable<int>>(1, <int>[6, 7]),
              MapEntry<int?, Iterable<int>>(10, <int>[10]),
            ],
          ),
        );

        expect(rxList.value.listView, <int>[4, 5, 1, 6, 7, 2, 3, 10]);

        expect(change!.added[0], 4);
        expect(change.added[1], 5);
        expect(change.added[3], 6);
        expect(change.added[4], 7);
        expect(change.added[7], 10);
      });

      test('Should apply add action to the list based on the added items with different order', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.applyAction(
          ObservableListUpdateAction<int>.add(
            <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(1, <int>[6, 7]),
              MapEntry<int?, Iterable<int>>(0, <int>[4, 5]),
              MapEntry<int?, Iterable<int>>(10, <int>[10]),
            ],
          ),
        );

        expect(rxList.value.listView, <int>[4, 5, 1, 6, 7, 2, 3, 10]);

        expect(change!.added[0], 4);
        expect(change.added[1], 5);
        expect(change.added[3], 6);
        expect(change.added[4], 7);
        expect(change.added[7], 10);
      });

      test('Should apply remove action to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.applyAction(
          ObservableListUpdateAction<int>.remove(
            <int>{1, 2},
          ),
        );

        expect(rxList.value.listView, <int>[1]);
      });

      test('Should apply update action to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.applyAction(
          ObservableListUpdateAction<int>.update(
            <int, int>{
              0: 4,
              1: 5,
              5: 10,
            },
          ),
        );

        expect(rxList.value.listView, <int>[4, 5, 3, 10]);
      });
    });

    group('setData', () {
      test('Should set the list data', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.setData(<int>[4, 5, 3, 6]);

        expect(change, isNotNull);
        expect(change!.added, <int, int>{
          3: 6,
        });
        expect(change.removed, <int, int>{});
        expect(change.updated, <int, ObservableItemChange<int>>{
          0: ObservableItemChange<int>(oldValue: 1, newValue: 4),
          1: ObservableItemChange<int>(oldValue: 2, newValue: 5),
        });

        expect(rxList.value.listView, <int>[4, 5, 3, 6]);
      });

      test('Should set the list data with empty list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableListChange<int>? change = rxList.setData(<int>[]);

        expect(change, isNotNull);
        expect(change!.added, <int, int>{});
        expect(change.removed, <int, int>{
          0: 1,
          1: 2,
          2: 3,
        });
        expect(change.updated, <int, ObservableItemChange<int>>{});

        expect(rxList.value.listView, <int>[]);
      });
    });
  });
}
