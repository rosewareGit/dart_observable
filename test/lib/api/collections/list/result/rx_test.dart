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

        rxList.failure = 'failure';
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

        rxList.add(4);
        expect(rxList[3], 4);
      });

      test('Should add the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.add(4);
        expect(rxList[0], 4);
      });

      test('Should add the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.add(4);
        expect(rxList[0], 4);
      });
    });

    group('addAll', () {
      test('Should add all items', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.addAll(<int>[4, 5]);
        expect(rxList[3], 4);
        expect(rxList[4], 5);
      });

      test('Should add all items when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.addAll(<int>[4, 5]);
        expect(rxList[0], 4);
        expect(rxList[1], 5);
      });

      test('Should add all items when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.addAll(<int>[4, 5]);
        expect(rxList[0], 4);
        expect(rxList[1], 5);
      });
    });

    group('applyAction', () {
      test('Should apply the action - data', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.applyAction(
          ObservableListResultUpdateActionData<int, dynamic>.add(
            <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(3, <int>[4]),
            ],
          ),
        );
        expect(rxList[3], 4);
      });

      test('Should apply the action - failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.applyAction(
          ObservableListResultUpdateActionFailure<int, dynamic>(failure: 'failure'),
        );
        expect(rxList.value is ObservableListResultStateFailure, true);
      });

      test('Should apply the action - undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.applyAction(
          ObservableListResultUpdateActionUndefined<int, dynamic>(),
        );
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });
    });

    group('clear', () {
      test('Should clear the list', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.clear();
        expect(rxList.value is ObservableListResultStateData, true);
        expect((rxList.value as ObservableListResultStateData<int, dynamic>).data.isEmpty, true);
      });

      test('Should not do anything if the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.clear();
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });

      test('Should not do anything if the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.clear();
        expect(rxList.value is ObservableListResultStateFailure, true);
      });
    });

    group('insert', () {
      test('Should insert the item', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.insert(1, 4);
        expect(rxList[1], 4);
        expect(rxList[2], 2);
      });

      test('Should insert the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.insert(0, 4);
        expect(rxList[0], 4);
      });

      test('Should insert the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.insert(0, 4);
        expect(rxList[0], 4);
      });
    });

    group('insertAll', () {
      test('Should insert all items', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.insertAll(1, <int>[4, 5]);
        expect(rxList[1], 4);
        expect(rxList[2], 5);
        expect(rxList[3], 2);
      });

      test('Should insert all items when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.insertAll(0, <int>[4, 5]);
        expect(rxList[0], 4);
        expect(rxList[1], 5);
      });

      test('Should insert all items when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.insertAll(0, <int>[4, 5]);
        expect(rxList[0], 4);
        expect(rxList[1], 5);
      });
    });

    group('remove', () {
      test('Should remove the item', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.remove(2);
        expect(rxList[1], 3);
      });

      test('Should remove the item when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.remove(2);
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });

      test('Should remove the item when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.remove(2);
        expect(rxList.value is ObservableListResultStateFailure, true);
      });
    });

    group('removeAt', () {
      test('Should remove the item at the given position', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.removeAt(1);
        expect(rxList[1], 3);
      });

      test('Should remove the item at the given position when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.removeAt(1);
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });

      test('Should remove the item at the given position when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.removeAt(1);
        expect(rxList.value is ObservableListResultStateFailure, true);
      });
    });

    group('removeWhere', () {
      test('Should remove the items that match the predicate', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.removeWhere((final int item) => item == 2);
        expect(rxList[0], 1);
        expect(rxList[1], 3);
      });

      test('Should remove the items that match the predicate when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.removeWhere((final int item) => item == 2);
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });

      test('Should remove the items that match the predicate when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.removeWhere((final int item) => item == 2);
        expect(rxList.value is ObservableListResultStateFailure, true);
      });
    });

    group('setUndefined', () {
      test('Should set the state to undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        rxList.setUndefined();
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });

      test('Should set the state to undefined when the state is undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.setUndefined();
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });

      test('Should set the state to undefined when the state is failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>();
        expect(rxList.value is ObservableListResultStateUndefined, true);

        rxList.failure = 'failure';
        expect(rxList.value is ObservableListResultStateFailure, true);

        rxList.setUndefined();
        expect(rxList.value is ObservableListResultStateUndefined, true);
      });
    });
  });
}
