import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxListUndefined', () {
    group('undefined', () {
      test('Should set to undefined', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>();
        rxList.setUndefined();
        expect(rxList.value.custom, Undefined());
      });
    });

    group('applyAction', () {
      test('Should apply data action', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableListUpdateAction<int>, Undefined> action =
            StateOf<ObservableListUpdateAction<int>, Undefined>.data(
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

        final StateOf<ObservableListChange<int>, Undefined>? result = rxList.applyAction(action);
        expect(result!.data!.added, <int, int>{0: 100, 1: 101});
        expect(result.data!.removed, <int, int>{1: 2});
        expect(
          result.data!.updated,
          <int, ObservableItemChange<int>>{0: ObservableItemChange<int>(oldValue: 1, newValue: 1000)},
        );
      });

      test('Should apply undefined action', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableListUpdateAction<int>, Undefined> action =
            StateOf<ObservableListUpdateAction<int>, Undefined>.custom(Undefined());

        final StateOf<ObservableListChange<int>, Undefined>? result = rxList.applyAction(action);
        expect(result!.custom, Undefined());
      });
    });

    group('applyListUpdateAction', () {
      test('Should apply data action', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>(
          insertItemAtPosition: <MapEntry<int?, Iterable<int>>>[
            MapEntry<int?, Iterable<int>>(0, <int>[100, 101]),
          ],
          removeIndexes: <int>{1},
          updateItemAtPosition: <int, int>{
            0: 1000,
          },
        );

        final ObservableListChange<int>? change = rxList.applyListUpdateAction(action);
        expect(change!.added, <int, int>{0: 100, 1: 101});
        expect(change.removed, <int, int>{1: 2});
        expect(
          change.updated,
          <int, ObservableItemChange<int>>{0: ObservableItemChange<int>(oldValue: 1, newValue: 1000)},
        );
      });
    });

    group('setState', () {
      test('Should set state', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableListChange<int>, Undefined>? result = rxList.setState(Undefined());
        expect(rxList.value.custom, Undefined());
        expect(result!.custom, Undefined());
      });
    });

    group('asObservable', () {
      test('Should return the same instance but with observable type', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        final ObservableListUndefined<int> observableList = rxList.asObservable();
        expect(observableList, rxList);
      });
    });

    group('operator []=', () {
      test('Should set value at index', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList[0] = 100;
        expect(rxList.value.data!.listView, <int>[100, 2, 3]);

        rxList.setUndefined();
        rxList[0] = 1000;

        expect(rxList.value.data!.listView, <int>[1000]);
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.add(100);
        expect(rxList.value.data!.listView, <int>[1, 2, 3, 100]);

        rxList.setUndefined();
        rxList.add(1000);

        expect(rxList.value.data!.listView, <int>[1000]);
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.addAll(<int>[100, 101]);
        expect(rxList.value.data!.listView, <int>[1, 2, 3, 100, 101]);

        rxList.setUndefined();
        rxList.addAll(<int>[1000, 1001]);

        expect(rxList.value.data!.listView, <int>[1000, 1001]);
      });
    });

    group('clear', () {
      test('Should clear values', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.clear();
        expect(rxList.value.data!.listView, <int>[]);

        rxList.setUndefined();
        rxList.clear();

        expect(rxList.value.data!.listView, <int>[]);
      });
    });

    group('insert', () {
      test('Should insert value at index', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.insert(0, 100);
        expect(rxList.value.data!.listView, <int>[100, 1, 2, 3]);

        rxList.setUndefined();
        rxList.insert(0, 1000);

        expect(rxList.value.data!.listView, <int>[1000]);
      });
    });

    group('insertAll', () {
      test('Should insert all values at index', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.insertAll(0, <int>[100, 101]);
        expect(rxList.value.data!.listView, <int>[100, 101, 1, 2, 3]);

        rxList.setUndefined();
        rxList.insertAll(0, <int>[1000, 1001]);

        expect(rxList.value.data!.listView, <int>[1000, 1001]);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.remove(2);
        expect(rxList.value.data!.listView, <int>[1, 3]);

        rxList.setUndefined();
        rxList.remove(3);

        expect(rxList.value.data!.listView, <int>[]);
      });
    });

    group('removeAt', () {
      test('Should remove value at index', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.removeAt(1);
        expect(rxList.value.data!.listView, <int>[1, 3]);

        rxList.setUndefined();
        rxList.removeAt(0);

        expect(rxList.value.data!.listView, <int>[]);
      });
    });

    group('removeWhere', () {
      test('Should remove values where predicate is true', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.removeWhere((final int item) => item == 2);
        expect(rxList.value.data!.listView, <int>[1, 3]);

        rxList.setUndefined();
        rxList.removeWhere((final int item) => item == 3);

        expect(rxList.value.data!.listView, <int>[]);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxListUndefined<int> rxList = RxListUndefined<int>(initial: <int>[1, 2, 3]);
        rxList.setData(<int>[100, 101]);
        expect(rxList.value.data!.listView, <int>[100, 101]);

        rxList.setUndefined();
        rxList.setData(<int>[1000, 1001]);

        expect(rxList.value.data!.listView, <int>[1000, 1001]);
      });
    });
  });
}
