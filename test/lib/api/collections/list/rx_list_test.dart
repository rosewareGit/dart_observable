import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxList', () {
    group('value', () {
      test('Should return an unmodifiable list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final List<int> value = rxList.value;
        expect(() => value.add(4), throwsUnsupportedError);
      });

      test('Should set the new list value', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.value = <int>[4, 5, 6];
        expect(rxList.change.updated.length, 3);
        expect(rxList.value, <int>[4, 5, 6]);

        rxList.value = <int>[];
        expect(rxList.change.removed.length, 3);
        expect(rxList.value, <int>[]);

        rxList.value = <int>[1, 2, 3];
        expect(rxList.change.added.length, 3);
        expect(rxList.value, <int>[1, 2, 3]);

        rxList.value = <int>[1, 2, 3, 4];
        expect(rxList.change.added.length, 1);
        expect(rxList.change.updated.length, 0);
        expect(rxList.change.removed.length, 0);

        expect(rxList.value, <int>[1, 2, 3, 4]);
      });
    });

    group('[]=', () {
      test('Should set the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList[0] = 4;
        expect(rxList[0], 4);
      });

      test('Should add the item if the index is greater than the length of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList[10] = 4;
        expect(rxList.value, <int>[1, 2, 3, 4]);
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
        expect(rxList.value, <int>[1, 4, 2, 3]);
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
        expect(rxList.value, <int>[1, 3]);
        expect(rxList[1], 3);
        expect(change!.removed[1], 2);
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

        expect(rxList.value, <int>[4, 5, 3, 6]);
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

        expect(rxList.value, <int>[]);
      });
    });
  });
}
