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
      test('Data state: Should add the item', () {
        final RxStatefulList<int, dynamic> rxList = RxStatefulList<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final ObservableListChange<int>? changeData = rxList.add(4);
        expect(rxList[3], 4);
        expect(changeData!.added[3], 4);
      });

      test('Custom state: Should add the item', () {
        final RxStatefulList<int, dynamic> rxList = RxStatefulList<int, dynamic>(custom: 'custom');
        expect(rxList.value.rightOrNull, 'custom');

        final ObservableListChange<int>? changeData = rxList.add(4);
        expect(rxList[0], 4);
        expect(changeData!.added[0], 4);
      });
    });

    group('setState', () {
      test('Should set the custom state', () {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(
          initial: <int>[1, 2, 3],
        );

        final Either<ObservableListChange<int>, String>? changeData = rxList.setState('custom');
        expect(rxList.value.rightOrNull, 'custom');
        expect(changeData!.rightOrNull, 'custom');
      });
    });
  });
}
