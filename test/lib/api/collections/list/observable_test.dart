import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableList', () {
    group('operator []', () {
      test('Should return the item at the specified index', () {
        final ObservableList<int> rxList = ObservableList<int>(<int>[1, 2, 3]);

        expect(rxList[0], 1);
        expect(rxList[1], 2);
        expect(rxList[2], 3);
      });
    });

    group('length', () {
      test('Should return the length of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        expect(rxList.length, 3);
        rxList.removeAt(0);
        expect(rxList.length, 2);
        rxList.add(4);
        expect(rxList.length, 3);
      });
    });

    group('rxItem', () {
      test('Should return the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);

        rxItem.listen();

        expect(rxItem.value, 1);
        rxList[0] = 4;
        expect(rxItem.value, 4);
      });

      test('Should be the next item when item at the specified index is removed', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);

        rxItem.listen();

        expect(rxItem.value, 1);
        rxList.removeAt(0);
        expect(rxItem.value, 2);
      });

      test('Should be the updated item after listening', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);
        expect(rxItem.value, 1);
        rxList.removeAt(0);
        rxItem.listen();
        expect(rxItem.value, 2);
      });

      test('Should dispose when source is disposed', () async {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final Observable<int?> rxItem = rxList.rxItem(0);
        expect(rxItem.value, 1);
        await rxList.dispose();
        expect(rxItem.disposed, true);
      });

      test('Should pause when inactive', () async {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);

        final Observable<int?> rxItem = rxList.rxItem(0);
        Disposable listener = rxItem.listen();

        expect(rxItem.value, 1);
        await listener.dispose();

        rxList[0] = 4;
        expect(rxItem.value, 1);

        listener = rxItem.listen();
        expect(rxItem.value, 4);
      });

      test('Should be null if index is not set yet', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);

        final Observable<int?> rxItem = rxList.rxItem(3);
        expect(rxItem.value, null);
        rxItem.listen();

        expect(rxItem.value, null);

        rxList.add(4);

        expect(rxItem.value, 4);
      });
    });
  });
}
