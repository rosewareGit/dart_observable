import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableList', () {
    group('operator []', () {
      test('Should return the item at the specified index', () {
        final ObservableList<int> rxList = RxList<int>(<int>[1, 2, 3]);

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

    group('switchMap', () {
      test('Should switch to the new observable and listen', () async {
        final RxInt rxType1 = RxInt(1);
        final RxInt rxType2 = RxInt(2);
        final RxInt rxType3 = RxInt(3);

        final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3]);

        final Observable<int> rxSwitched = rxSource.switchMap<int>(
          (final ObservableListState<int> state) {
            final int mod = state.listView.length % 3;
            if (mod == 0) {
              return rxType1;
            } else if (mod == 1) {
              return rxType2;
            } else {
              return rxType3;
            }
          },
        );

        final Disposable listener = rxSwitched.listen();

        expect(rxSwitched.value, 1);
        rxType1.value = 4;
        expect(rxSwitched.value, 4);

        rxSource.add(4);
        expect(rxSwitched.value, 2, reason: 'Should switch to rxType2 because 4 % 3 == 1');
        rxType2.value = 5;
        expect(rxSwitched.value, 5);

        rxSource.add(5);
        expect(rxSwitched.value, 3, reason: 'Should switch to rxType3 because 5 % 3 == 2');
        rxType3.value = 6;
        expect(rxSwitched.value, 6);

        rxSource.removeAt(0);
        expect(rxSwitched.value, 5, reason: 'Should switch to rxType2 because 5 % 3 == 2');

        await listener.dispose();

        rxSource.add(6);
        expect(rxSwitched.value, 5, reason: 'Should not switch because listener is disposed');

        rxSwitched.listen();
        // Should switch after listening again
        expect(rxSwitched.value, 6, reason: 'Should switch to rxType3 because 6 % 3 == 0');

        final Observable<int> rxSwitched2 = rxSource.switchMap<int>(
          (final ObservableListState<int> state) {
            final int mod = state.listView.length % 3;
            if (mod == 0) {
              return rxType1;
            } else if (mod == 1) {
              return rxType2;
            } else {
              return rxType3;
            }
          },
        );

        rxSwitched2.listen();
        expect(rxSwitched2.value, 6, reason: 'Should switch to rxType3 because 6 % 3 == 0');

        await rxSource.dispose();
        expect(rxSwitched.disposed, true);
        expect(rxSwitched2.disposed, true);
      });
    });

    group('switchMapAs', () {
      group('map', () {
        test('Should switch to the new observable and listen', () async {
          final RxMap<int, String> rxType1 = RxMap<int, String>(<int, String>{1: '1'});
          final RxMap<int, String> rxType2 = RxMap<int, String>(<int, String>{2: '2'});
          final RxMap<int, String> rxType3 = RxMap<int, String>(<int, String>{3: '3'});

          final RxList<int> rxSource = RxList<int>(<int>[1, 2, 3]);

          final ObservableMap<int, String> rxSwitched = rxSource.switchMapAs.map<int, String>(
            mapper: (final ObservableListState<int> state) {
              final int mod = state.listView.length % 3;
              if (mod == 0) {
                return rxType1;
              } else if (mod == 1) {
                return rxType2;
              } else {
                return rxType3;
              }
            },
          );

          rxSwitched.listen();

          expect(rxSwitched.length, 1);
          expect(rxSwitched.value.mapView, <int, String>{1: '1'});

          rxType1[1] = '4';
          expect(rxSwitched.value.mapView, <int, String>{1: '4'});
          rxType1[2] = '5';
          expect(rxSwitched.value.mapView, <int, String>{1: '4', 2: '5'});

          rxSource.add(4);
          expect(rxSwitched.length, 1);
          expect(rxSwitched.value.mapView, <int, String>{2: '2'});

          rxSource.remove(4);
          expect(rxSwitched.length, 2);
          expect(rxSwitched.value.mapView, <int, String>{1: '4', 2: '5'});

          await rxSource.dispose();
          expect(rxSwitched.disposed, true);
        });
      });
    });
  });
}
