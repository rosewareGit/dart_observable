import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxListFailure', () {
    group('factory-failure', () {
      test('Should create RxListFailure with failure', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>.failure(failure: 'failure');
        expect(rxListFailure.value.custom, 'failure');
      });
    });

    group('failure', () {
      test('Should set failure', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>();
        rxListFailure.failure = 'failure';
        expect(rxListFailure.value.custom, 'failure');
      });
    });

    group('applyAction', () {
      test('Should apply data action', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableListUpdateAction<int>, String> action =
            StateOf<ObservableListUpdateAction<int>, String>.data(
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

        final StateOf<ObservableListChange<int>, String>? result = rxListFailure.applyAction(action);
        expect(result!.data!.added, <int, int>{0: 100, 1: 101});
        expect(result.data!.removed, <int, int>{1: 2});
        expect(
          result.data!.updated,
          <int, ObservableItemChange<int>>{0: ObservableItemChange<int>(oldValue: 1, newValue: 1000)},
        );
      });

      test('Should apply failure action', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableListUpdateAction<int>, String> action =
            StateOf<ObservableListUpdateAction<int>, String>.custom('failure');

        final StateOf<ObservableListChange<int>, String>? result = rxListFailure.applyAction(action);
        expect(result!.custom, 'failure');
      });
    });

    group('applyListUpdateAction', () {
      test('Should apply data action', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableListUpdateAction<int> action = ObservableListUpdateAction<int>(
          insertItemAtPosition: <MapEntry<int?, Iterable<int>>>[
            MapEntry<int?, Iterable<int>>(0, <int>[100, 101]),
          ],
          removeIndexes: <int>{1},
          updateItemAtPosition: <int, int>{
            0: 1000,
          },
        );

        final ObservableListChange<int>? change = rxListFailure.applyListUpdateAction(action);
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
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        final StateOf<ObservableListChange<int>, String>? result = rxListFailure.setState('state');
        expect(rxListFailure.value.custom, 'state');
        expect(result!.custom, 'state');

        final StateOf<ObservableListChange<int>, String>? result2 = rxListFailure.setState('state2');
        expect(rxListFailure.value.custom, 'state2');
        expect(result2!.custom, 'state2');
      });
    });

    group('asObservable', () {
      test('Should return the same instance but with observable type', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableListFailure<int, String> observableList = rxListFailure.asObservable();
        expect(observableList, rxListFailure);
      });
    });

    group('operator []=', () {
      test('Should set value at index', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure[0] = 100;
        expect(rxListFailure.value.data!.listView, <int>[100, 2, 3]);

        rxListFailure.failure = 'failure';
        rxListFailure[0] = 1000;

        expect(rxListFailure.value.data!.listView, <int>[1000]);
      });
    });

    group('add', () {
      test('Should add value', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.add(100);
        expect(rxListFailure.value.data!.listView, <int>[1, 2, 3, 100]);

        rxListFailure.failure = 'failure';
        rxListFailure.add(1000);

        expect(rxListFailure.value.data!.listView, <int>[1000]);
      });
    });

    group('addAll', () {
      test('Should add all values', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.addAll(<int>[100, 101]);
        expect(rxListFailure.value.data!.listView, <int>[1, 2, 3, 100, 101]);

        rxListFailure.failure = 'failure';
        rxListFailure.addAll(<int>[1000, 1001]);

        expect(rxListFailure.value.data!.listView, <int>[1000, 1001]);
      });
    });

    group('clear', () {
      test('Should clear values', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.clear();
        expect(rxListFailure.value.data!.listView, <int>[]);

        rxListFailure.failure = 'failure';
        rxListFailure.clear();

        expect(rxListFailure.value.data!.listView, <int>[]);
      });
    });

    group('insert', () {
      test('Should insert value at index', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.insert(0, 100);
        expect(rxListFailure.value.data!.listView, <int>[100, 1, 2, 3]);

        rxListFailure.failure = 'failure';
        rxListFailure.insert(0, 1000);

        expect(rxListFailure.value.data!.listView, <int>[1000]);
      });
    });

    group('insertAll', () {
      test('Should insert all values at index', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.insertAll(0, <int>[100, 101]);
        expect(rxListFailure.value.data!.listView, <int>[100, 101, 1, 2, 3]);

        rxListFailure.failure = 'failure';
        rxListFailure.insertAll(0, <int>[1000, 1001]);

        expect(rxListFailure.value.data!.listView, <int>[1000, 1001]);
      });
    });

    group('remove', () {
      test('Should remove value', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.remove(2);
        expect(rxListFailure.value.data!.listView, <int>[1, 3]);

        rxListFailure.failure = 'failure';
        rxListFailure.remove(3);

        expect(rxListFailure.value.data!.listView, <int>[]);
      });
    });

    group('removeAt', () {
      test('Should remove value at index', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.removeAt(1);
        expect(rxListFailure.value.data!.listView, <int>[1, 3]);

        rxListFailure.failure = 'failure';
        rxListFailure.removeAt(0);

        expect(rxListFailure.value.data!.listView, <int>[]);
      });
    });

    group('removeWhere', () {
      test('Should remove values where predicate is true', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.removeWhere((final int item) => item == 2);
        expect(rxListFailure.value.data!.listView, <int>[1, 3]);

        rxListFailure.failure = 'failure';
        rxListFailure.removeWhere((final int item) => item == 3);

        expect(rxListFailure.value.data!.listView, <int>[]);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxListFailure<int, String> rxListFailure = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        rxListFailure.setData(<int>[100, 101]);
        expect(rxListFailure.value.data!.listView, <int>[100, 101]);

        rxListFailure.failure = 'failure';
        rxListFailure.setData(<int>[1000, 1001]);

        expect(rxListFailure.value.data!.listView, <int>[1000, 1001]);
      });
    });
  });
}
