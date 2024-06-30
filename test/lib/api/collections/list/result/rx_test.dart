import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxListResult', () {
    group('operator []=', () {
      test('Should set the item on the given position', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList[0] = 4;
        expect(rxList[0], 4);
      });

      test('Should set the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList[0] = 4;
        expect(rxList[0], 4);
      });

      test('Should set the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList[0] = 4;
        expect(rxList[0], 4);
      });
    });

    group('add', () {
      test('Should add the item', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.add(4) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[3], 4);
        expect(changeData.change.added[3], 4);
      });

      test('Should add the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.add(4) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(changeData.change.added[0], 4);
      });

      test('Should add the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.add(4) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(changeData.change.added[0], 4);
      });
    });

    group('addAll', () {
      test('Should add all items', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.addAll(<int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[3], 4);
        expect(rxList[4], 5);
        expect(changeData.change.added[3], 4);
        expect(changeData.change.added[4], 5);
      });

      test('Should add all items when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.addAll(<int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(rxList[1], 5);
        expect(changeData.change.added[0], 4);
        expect(changeData.change.added[1], 5);
      });

      test('Should add all items when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.addAll(<int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(rxList[1], 5);
        expect(changeData.change.added[0], 4);
        expect(changeData.change.added[1], 5);
      });
    });

    group('setFailure', () {
      test('Should set the failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeFailure<int, dynamic> changeData =
            rxList.setFailure('failure') as ObservableListResultChangeFailure<int, dynamic>;
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changeData.failure, 'failure');
        expect(changeData.removedItems, <int>[1, 2, 3]);
      });

      test('Should return null and do nothing when the state is already failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChange<int, dynamic>? changeData = rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changeData, isNull);
      });

      test('Should update to new failure if state is in different failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeFailure<int, dynamic> changeData =
            rxList.setFailure('failure') as ObservableListResultChangeFailure<int, dynamic>;
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changeData.failure, 'failure');
        expect(changeData.removedItems, <int>[1, 2, 3]);

        final ObservableListResultChangeFailure<int, dynamic> changeData2 =
            rxList.setFailure('failure2') as ObservableListResultChangeFailure<int, dynamic>;
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changeData2.failure, 'failure2');
        expect(changeData2.removedItems.isEmpty, true);
      });
    });

    group('applyAction', () {
      test('Should apply the action - data', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData = rxList.applyAction(
          ObservableListResultUpdateActionData<int, dynamic>.add(
            <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(3, <int>[4]),
            ],
          ),
        ) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[3], 4);
        expect(changeData.change.added[3], 4);
      });

      test('Should apply the action - failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeFailure<int, dynamic> changeData = rxList.applyAction(
          ObservableListResultUpdateActionFailure<int, dynamic>(failure: 'failure'),
        ) as ObservableListResultChangeFailure<int, dynamic>;
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changeData.failure, 'failure');
        expect(changeData.removedItems, <int>[1, 2, 3]);
      });

      test('Should apply the action - undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeUndefined<int, dynamic> changeData = rxList.applyAction(
          ObservableListResultUpdateActionUndefined<int, dynamic>(),
        ) as ObservableListResultChangeUndefined<int, dynamic>;
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changeData.removedItems, <int>[1, 2, 3]);
      });
    });

    group('clear', () {
      test('Should clear the list', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.clear() as ObservableListResultChangeData<int, dynamic>;
        expect(rxList.value is ObservableListResultStateData, true);
        expect((rxList.value as ObservableListResultStateData<int, dynamic>).data.isEmpty, true);
        expect(changeData.change.removed, <int, int>{
          0: 1,
          1: 2,
          2: 3,
        });
      });

      test('Should not do anything if the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChange<int, dynamic>? changeData = rxList.clear();
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changeData, isNull);
      });

      test('Should not do anything if the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChange<int, dynamic>? changeData = rxList.clear();
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changeData, isNull);
      });
    });

    group('insert', () {
      test('Should insert the item', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.insert(1, 4) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[1], 4);
        expect(rxList[2], 2);
        expect(
          changeData.change.added,
          <int, int>{
            1: 4,
          },
        );
      });

      test('Should insert the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.insert(0, 4) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(changeData.change.added[0], 4);
      });

      test('Should insert the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.insert(0, 4) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(changeData.change.added[0], 4);
      });
    });

    group('insertAll', () {
      test('Should insert all items', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.insertAll(1, <int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[1], 4);
        expect(rxList[2], 5);
        expect(rxList[3], 2);
        expect(
          changeData.change.added,
          <int, int>{
            1: 4,
            2: 5,
          },
        );
      });

      test('Should insert all items when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.insertAll(0, <int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(rxList[1], 5);
        expect(changeData.change.added, <int, int>{
          0: 4,
          1: 5,
        });
      });

      test('Should insert all items when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.insertAll(0, <int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 4);
        expect(rxList[1], 5);
        expect(changeData.change.added, <int, int>{
          0: 4,
          1: 5,
        });
      });
    });

    group('remove', () {
      test('Should remove the item', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.remove(2) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[1], 3);
        expect(changeData.change.removed[1], 2);
      });

      test('Should not remove the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChange<int, dynamic>? changeData = rxList.remove(2);
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changeData, isNull);
      });

      test('Should not remove the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChange<int, dynamic>? changedData = rxList.remove(2);
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changedData, isNull);
      });
    });

    group('removeAt', () {
      test('Should remove the item at the given position', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.removeAt(1) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[1], 3);
        expect(changeData.change.removed[1], 2);
      });

      test('Should remove the item at the given position when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChange<int, dynamic>? changedData = rxList.removeAt(1);
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changedData, isNull);
      });

      test('Should remove the item at the given position when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChange<int, dynamic>? changedData = rxList.removeAt(1);
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changedData, isNull);
      });
    });

    group('removeWhere', () {
      test('Should remove the items that match the predicate', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeData<int, dynamic> changeData =
            rxList.removeWhere((final int item) => item == 2) as ObservableListResultChangeData<int, dynamic>;
        expect(rxList[0], 1);
        expect(rxList[1], 3);
        expect(changeData.change.removed[1], 2);
      });

      test('Should remove the items that match the predicate when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChange<int, dynamic>? changedData = rxList.removeWhere((final int item) => item == 2);
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changedData, isNull);
      });

      test('Should remove the items that match the predicate when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChange<int, dynamic>? changedData = rxList.removeWhere((final int item) => item == 2);
        expect(rxList.value is ObservableListResultStateFailure, true);
        expect(changedData, isNull);
      });
    });

    group('setUndefined', () {
      test('Should set the state to undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListResultChangeUndefined<int, dynamic> change =
            rxList.setUndefined() as ObservableListResultChangeUndefined<int, dynamic>;
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(change.removedItems, <int>[1, 2, 3]);
      });

      test('Should not return any change when state is already undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        final ObservableListResultChange<int, dynamic>? changeData = rxList.setUndefined();
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changeData, isNull);
      });

      test('Should set the state to undefined when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setFailure('failure');
        expect(rxList.value is ObservableListResultStateFailure, true);

        final ObservableListResultChangeUndefined<int, dynamic> changedData =
            rxList.setUndefined() as ObservableListResultChangeUndefined<int, dynamic>;
        expect(rxList.value is ObservableListResultStateUndefined, true);
        expect(changedData.removedItems.length, 0);
      });
    });
  });
}
