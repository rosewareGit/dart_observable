import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxListEmptyResult', () {
    group('value', () {
      test('Should return an unmodifiable list', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        expect(() => list.value.leftOrThrow.add(4), throwsUnsupportedError);
      });

      test('Should set new state value', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        list.value = Either<List<int>, String>.right('custom');
        expect(list.change.rightOrThrow, 'custom');
        expect(list.value.rightOrNull, 'custom');
      });

      test('Should set new list value', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        list.value = Either<List<int>, String>.left(<int>[2, 3, 4, 5]);
        final ObservableListChange<int> change = list.change.leftOrThrow;
        expect(change.removed.length, 0);
        expect(change.updated.length, 3);
        expect(change.updated[0]!.oldValue, 1);
        expect(change.updated[0]!.newValue, 2);
        expect(change.updated[1]!.oldValue, 2);
        expect(change.updated[1]!.newValue, 3);
        expect(change.updated[2]!.oldValue, 3);
        expect(change.updated[2]!.newValue, 4);
        expect(change.added.length, 1);
        expect(change.added[3], 5);
        expect(list.value.leftOrNull, <int>[2, 3, 4, 5]);

        list.value = Either<List<int>, String>.left(<int>[]);
        expect(list.change.leftOrThrow.removed.length, 4);
        expect(list.value.leftOrNull, <int>[]);

        list.value = Either<List<int>, String>.left(<int>[1, 2, 3]);
        expect(list.change.leftOrThrow.added.length, 3);
        expect(list.value.leftOrNull, <int>[1, 2, 3]);

        list.value = Either<List<int>, String>.left(<int>[1, 2, 3, 4]);
        expect(list.change.leftOrThrow.added.length, 1);
        expect(list.change.leftOrThrow.updated.length, 0);
        expect(list.change.leftOrThrow.removed.length, 0);
        expect(list.value.leftOrNull, <int>[1, 2, 3, 4]);
      });
    });

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
        expect(rxList.value.leftOrNull!, <int>[4]);
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

        final StatefulListChange<int, String>? changeData = rxList.setState('custom');
        expect(rxList.value.rightOrNull, 'custom');
        expect(changeData!.rightOrNull, 'custom');
      });
    });
  });
}
