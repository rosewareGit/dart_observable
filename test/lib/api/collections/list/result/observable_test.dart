import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableListResult', () {
    group('operator []', () {
      test('Should return the item on the given position', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        expect(rxList[0], 1);
        expect(rxList[1], 2);
        expect(rxList[2], 3);
        expect(rxList[3], null);
      });

      test('Should return null when undefined', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: null,
        );

        expect(rxList[0], null);
      });

      test('Should return null when failure', () {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: null,
        );

        rxList.setFailure('failure');
        expect(rxList[0], null);
      });
    });

    group('rxItem', () {
      test('Should return the item on the given position', () async {
        final RxListResult<int, dynamic> rxList = RxListResult<int, dynamic>(
          initial: <int>[1, 2, 3],
        );

        final Observable<int?> rxItem = rxList.rxItem(0);
        rxItem.listen();
        expect(rxItem.value, 1);

        rxList[0] = 4;
        expect(rxItem.value, 4);

        rxList.clear();

        expect(rxItem.value, null);

        await rxList.dispose();
        expect(rxItem.disposed, true);
      });
    });
  });
}
