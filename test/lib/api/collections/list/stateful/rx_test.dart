import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxListEmptyResult', () {
    group('operator []=', () {
      test('Should set the item on the given position', () {
        final RxStatefulList<int, dynamic> rxList = RxStatefulList<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList[0] = 4;
        expect(rxList[0], 4);
      });

      test('Should set the item when the state is custom', () {
        final RxStatefulList<int, dynamic> rxList = RxStatefulList<int, dynamic>(custom: 'custom');
        expect(rxList.value.rightOrNull, 'custom');
        expect(rxList.value.leftOrNull, null);

        rxList[0] = 4;
        expect(rxList[0], 4);

        expect(rxList.value.rightOrNull, null);
        expect(rxList.value.leftOrNull!.listView, <int>[4]);
      });
    });

    group('add', () {
      test('Should add the item', () {
        final RxStatefulList<int, dynamic> rxList = RxStatefulList<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListChange<int>? changeData = rxList.add(4);
        expect(rxList[3], 4);
        expect(changeData!.added[3], 4);
      });

      test('Should add the item when the state is custom', () {
        final RxStatefulList<int, dynamic> rxList = RxStatefulList<int, dynamic>(custom: 'custom');
        expect(rxList.value.rightOrNull, 'custom');

        final ObservableListChange<int>? changeData = rxList.add(4);
        expect(rxList[0], 4);
        expect(changeData!.added[0], 4);
      });
    });

    //
    // group('addAll', () {
    //   test('Should add all items', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.addAll(<int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[3], 4);
    //     expect(rxList[4], 5);
    //     expect(changeData.change.added[3], 4);
    //     expect(changeData.change.added[4], 5);
    //   });
    //
    //   test('Should add all items when the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.addAll(<int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 4);
    //     expect(rxList[1], 5);
    //     expect(changeData.change.added[0], 4);
    //     expect(changeData.change.added[1], 5);
    //   });
    //
    //   test('Should add all items when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.addAll(<int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 4);
    //     expect(rxList[1], 5);
    //     expect(changeData.change.added[0], 4);
    //     expect(changeData.change.added[1], 5);
    //   });
    // });
    //
    // group('setFailure', () {
    //   test('Should set the failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeFailure<int, dynamic> changeData =
    //         rxList.setFailure('custom') as ObservableListResultChangeFailure<int, dynamic>;
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changeData.failure, 'custom');
    //     expect(changeData.removedItems, <int>[1, 2, 3]);
    //   });
    //
    //   test('Should return null and do nothing when the state is already failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changeData = rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changeData, isNull);
    //   });
    //
    //   test('Should update to new failure if state is in different failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeFailure<int, dynamic> changeData =
    //         rxList.setFailure('custom') as ObservableListResultChangeFailure<int, dynamic>;
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changeData.failure, 'custom');
    //     expect(changeData.removedItems, <int>[1, 2, 3]);
    //
    //     final ObservableListResultChangeFailure<int, dynamic> changeData2 =
    //         rxList.setFailure('failure2') as ObservableListResultChangeFailure<int, dynamic>;
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changeData2.failure, 'failure2');
    //     expect(changeData2.removedItems.isEmpty, true);
    //   });
    // });
    //
    group('applyAction', () {
      test('Should apply the action - data action', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListChange<int>? changeData = rxList.applyListUpdateAction(
          ObservableListUpdateAction<int>.add(
            <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(3, <int>[4]),
            ],
          ),
        );
        expect(rxList[3], 4);
        expect(changeData!.added[3], 4);
      });

      test('Should apply the action - custom', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(
          initial: <int>[1, 2, 3],
        );

        final Either<ObservableListChange<int>, String>? changeData = rxList.setState('custom');
        expect(rxList.value.rightOrNull, 'custom');
        expect(changeData!.rightOrNull, 'custom');
      });

      test('Should apply the action - empty', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(
          initial: <int>[1, 2, 3],
        );

        rxList.setState('custom');
        expect(rxList.value.rightOrNull, 'custom');
      });
    });
    //
    // group('clear', () {
    //   test('Should clear the list', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.clear() as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList.value is ObservableListResultStateData, true);
    //     expect((rxList.value as ObservableListResultStateData<int, dynamic>).data.isEmpty, true);
    //     expect(changeData.change.removed, <int, int>{
    //       0: 1,
    //       1: 2,
    //       2: 3,
    //     });
    //   });
    //
    //   test('Should not do anything if the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changeData = rxList.clear();
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(changeData, isNull);
    //   });
    //
    //   test('Should not do anything if the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changeData = rxList.clear();
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changeData, isNull);
    //   });
    // });
    //
    // group('insert', () {
    //   test('Should insert the item', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.insert(1, 4) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[1], 4);
    //     expect(rxList[2], 2);
    //     expect(
    //       changeData.change.added,
    //       <int, int>{
    //         1: 4,
    //       },
    //     );
    //   });
    //
    //   test('Should insert the item when the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.insert(0, 4) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 4);
    //     expect(changeData.change.added[0], 4);
    //   });
    //
    //   test('Should insert the item when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.insert(0, 4) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 4);
    //     expect(changeData.change.added[0], 4);
    //   });
    // });
    //
    // group('insertAll', () {
    //   test('Should insert all items', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.insertAll(1, <int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[1], 4);
    //     expect(rxList[2], 5);
    //     expect(rxList[3], 2);
    //     expect(
    //       changeData.change.added,
    //       <int, int>{
    //         1: 4,
    //         2: 5,
    //       },
    //     );
    //   });
    //
    //   test('Should insert all items when the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.insertAll(0, <int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 4);
    //     expect(rxList[1], 5);
    //     expect(changeData.change.added, <int, int>{
    //       0: 4,
    //       1: 5,
    //     });
    //   });
    //
    //   test('Should insert all items when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.insertAll(0, <int>[4, 5]) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 4);
    //     expect(rxList[1], 5);
    //     expect(changeData.change.added, <int, int>{
    //       0: 4,
    //       1: 5,
    //     });
    //   });
    // });
    //
    // group('remove', () {
    //   test('Should remove the item', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.remove(2) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[1], 3);
    //     expect(changeData.change.removed[1], 2);
    //   });
    //
    //   test('Should not remove the item when the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changeData = rxList.remove(2);
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(changeData, isNull);
    //   });
    //
    //   test('Should not remove the item when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changedData = rxList.remove(2);
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changedData, isNull);
    //   });
    // });
    //
    // group('removeAt', () {
    //   test('Should remove the item at the given position', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.removeAt(1) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[1], 3);
    //     expect(changeData.change.removed[1], 2);
    //   });
    //
    //   test('Should remove the item at the given position when the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changedData = rxList.removeAt(1);
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(changedData, isNull);
    //   });
    //
    //   test('Should remove the item at the given position when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changedData = rxList.removeAt(1);
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changedData, isNull);
    //   });
    // });
    //
    // group('removeWhere', () {
    //   test('Should remove the items that match the predicate', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeData<int, dynamic> changeData =
    //         rxList.removeWhere((final int item) => item == 2) as ObservableListResultChangeData<int, dynamic>;
    //     expect(rxList[0], 1);
    //     expect(rxList[1], 3);
    //     expect(changeData.change.removed[1], 2);
    //   });
    //
    //   test('Should remove the items that match the predicate when the state is undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changedData = rxList.removeWhere((final int item) => item == 2);
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(changedData, isNull);
    //   });
    //
    //   test('Should remove the items that match the predicate when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changedData = rxList.removeWhere((final int item) => item == 2);
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //     expect(changedData, isNull);
    //   });
    // });
    //
    // group('setUndefined', () {
    //   test('Should set the state to undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>(
    //       initial: <int>[1, 2, 3],
    //     );
    //
    //     final ObservableListResultChangeUndefined<int, dynamic> change =
    //         rxList.setUndefined() as ObservableListResultChangeUndefined<int, dynamic>;
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(change.removedItems, <int>[1, 2, 3]);
    //   });
    //
    //   test('Should not return any change when state is already undefined', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     final ObservableListResultChange<int, dynamic>? changeData = rxList.setUndefined();
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(changeData, isNull);
    //   });
    //
    //   test('Should set the state to undefined when the state is failure', () {
    //     final RxListEmptyResult<int, dynamic> rxList = RxListEmptyResult<int, dynamic>();
    //     expect(rxList.value is UndefinedFailure, true);
    //
    //     rxList.setFailure('custom');
    //     expect(rxList.value is ObservableListResultStateFailure, true);
    //
    //     final ObservableListResultChangeUndefined<int, dynamic> changedData =
    //         rxList.setUndefined() as ObservableListResultChangeUndefined<int, dynamic>;
    //     expect(rxList.value is UndefinedFailure, true);
    //     expect(changedData.removedItems.length, 0);
    //   });
    // });
  });
}
