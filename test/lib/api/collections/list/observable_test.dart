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

    group('changFactory', () {
      test('Should return a new ObservableList with the specified factory', () async {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        final ObservableList<int> rxList2 = rxList.changeFactory((final Iterable<int>? data) {
          return List<int>.of(data ?? <int>[]);
        });

        expect(rxList2.length, 0);

        rxList2.listen();

        expect(rxList2.length, 3);
        expect(rxList2.value.listView, <int>[1, 2, 3]);

        rxList.add(4);
        expect(rxList2.length, 4);
        expect(rxList2.value.listView, <int>[1, 2, 3, 4]);

        rxList.removeAt(0);
        expect(rxList2.length, 3);
        expect(rxList2.value.listView, <int>[2, 3, 4]);

        await rxList.dispose();
        expect(rxList2.disposed, true);
      });
    });

    group('filterItem', () {
      test('Should filter initial source list on listen', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        final ObservableList<int> filteredList = rxList.filterItem((final int item) => item % 2 == 0);

        expect(filteredList.length, 0);

        filteredList.listen();

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10]);
      });

      test('Should filter source list on change', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        final ObservableList<int> filteredList = rxList.filterItem((final int item) => item % 2 == 0);

        filteredList.listen();

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10]);

        // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        rxList.add(11);

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10]);

        // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] -> [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        rxList.add(12);

        expect(filteredList.length, 6);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10, 12]);

        // [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] -> [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        rxList.removeAt(0);

        expect(filteredList.length, 6);
        expect(filteredList.value.listView, <int>[2, 4, 6, 8, 10, 12]);

        // [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] -> [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        rxList.removeAt(0);

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[4, 6, 8, 10, 12]);

        // Update 4 -> 20
        rxList[1] = 20;

        expect(filteredList.length, 5);
        expect(filteredList.value.listView, <int>[20, 6, 8, 10, 12]);

        // Update 20 -> 3
        rxList[1] = 3;

        expect(filteredList.length, 4);
        expect(filteredList.value.listView, <int>[6, 8, 10, 12]);
      });
    });

    group('mapItem', () {
      test('Should map initial items on listen', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5']);
      });

      test('Should map changes', () {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5']);

        rxSource.add(6);

        expect(rxMapped.length, 6);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5', '6']);

        rxSource.removeAt(0);

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['2', '3', '4', '5', '6']);

        rxSource[0] = 7;

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['7', '3', '4', '5', '6']);
      });

      test('Should dispose when source disposed', () async {
        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3, 4, 5]);
        final ObservableList<String> rxMapped = rxSource.mapItem<String>(
          (final int item) => item.toString(),
        );

        rxMapped.listen();

        expect(rxMapped.length, 5);
        expect(rxMapped.value.listView, <String>['1', '2', '3', '4', '5']);

        await rxSource.dispose();

        expect(rxMapped.disposed, true);
      });
    });
  });
}
