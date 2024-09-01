import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableListFailure', () {
    group('length', () {
      test('should return the length of the list', () {
        final RxListFailure<int, String> list = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        expect(list.length.data, 3);

        list.add(4);
        expect(list.length.data, 4);

        list.failure = 'failure';
        expect(list.length.data, null);
        expect(list.length.custom, 'failure');
      });
    });

    group('lengthOrNull', () {
      test('should return the length of the list', () {
        final RxListFailure<int, String> list = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        expect(list.lengthOrNull, 3);

        list.add(4);
        expect(list.lengthOrNull, 4);

        list.failure = 'failure';
        expect(list.lengthOrNull, null);
      });
    });

    group('[]', () {
      test('should return the item at the given index', () {
        final RxListFailure<int, String> list = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        expect(list[0], 1);
        expect(list[1], 2);
        expect(list[2], 3);

        list.add(4);
        expect(list[3], 4);

        list.failure = 'failure';
        expect(list[0], null);
        expect(list[1], null);
        expect(list[2], null);
        expect(list[3], null);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the list', () async {
        final RxListFailure<int, String> rxList = RxListFailure<int, String>(initial: <int>[1, 2, 3]);
        final ObservableListFailure<int, String> rxNew = rxList.changeFactory((final Iterable<int>? items) {
          return List<int>.of(items ?? <int>[]);
        });

        rxNew.listen();

        expect(rxNew.value.data!.listView, <int>[1, 2, 3]);

        rxList.add(4);

        expect(rxNew.value.data!.listView, <int>[1, 2, 3, 4]);

        rxList.failure = 'failure';

        expect(rxNew.value.data, null);

        rxList.add(5);

        expect(rxNew.value.data!.listView, <int>[5]);

        await rxList.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the list', () async {
        final RxListFailure<int, String> rxList = RxListFailure<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableListFailure<int, String> rxNew = rxList.filterItem((final int item) => item.isOdd);

        rxNew.listen();
        expect(rxNew.value.data!.listView, <int>[1, 3, 5]);

        rxList.add(6);
        expect(rxNew.value.data!.listView, <int>[1, 3, 5]);

        rxList.add(7);
        expect(rxNew.value.data!.listView, <int>[1, 3, 5, 7]);

        rxList.remove(3);
        expect(rxNew.value.data!.listView, <int>[1, 5, 7]);

        rxList.failure = 'failure';
        expect(rxNew.value.data, null);

        rxList.add(8);
        expect(rxNew.value.data!.listView, <int>[]);

        rxList.add(9);
        expect(rxNew.value.data!.listView, <int>[9]);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.data!.listView, <int>[9, 11]);

        rxList.clear();
        expect(rxNew.value.data!.listView, <int>[]);

        await rxList.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item at the given index', () async {
        final RxListFailure<int, String> rxList = RxListFailure<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final Observable<StateOf<int?, String>> rxItem = rxList.rxItem(2);

        rxItem.listen();
        expect(rxItem.value.data, 3);

        rxList.add(6);
        expect(rxItem.value.data, 3);

        rxList.add(7);
        expect(rxItem.value.data, 3);

        rxList.remove(3);
        expect(rxItem.value.data, 4);

        rxList.removeAt(2);
        expect(rxItem.value.data, 5);

        rxList.failure = 'failure';
        expect(rxItem.value.data, null);
        expect(rxItem.value.custom, 'failure');

        rxList.add(8);
        expect(rxItem.value.data, null);

        rxList.add(9);
        expect(rxItem.value.data, null);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxItem.value.data, 10);

        rxList.clear();
        expect(rxItem.value.data, null);

        await rxList.dispose();

        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map initial failure state', () {
        final RxListFailure<int, String> rxList = RxListFailure<int, String>.failure(failure: 'failure');
        final ObservableListFailure<String, String> rxNew = rxList.mapItem((final int item) => item.toString());

        rxNew.listen();
        expect(rxNew.value.data, null);
        expect(rxNew.value.custom, 'failure');
      });

      test('Should map data change', () async {
        final RxListFailure<int, String> rxList = RxListFailure<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableListFailure<String, String> rxNew = rxList.mapItem((final int item) => item.toString());

        rxNew.listen();
        expect(rxNew.value.data!.listView, <String>['1', '2', '3', '4', '5']);

        rxList.add(6);
        expect(rxNew.value.data!.listView, <String>['1', '2', '3', '4', '5', '6']);

        rxList.add(7);
        expect(rxNew.value.data!.listView, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxList.remove(3);
        expect(rxNew.value.data!.listView, <String>['1', '2', '4', '5', '6', '7']);

        rxList.failure = 'failure';
        expect(rxNew.value.data, null);
        expect(rxNew.value.custom, 'failure');

        rxList.add(8);
        expect(rxNew.value.data!.listView, <String>['8']);

        rxList.add(9);
        expect(rxNew.value.data!.listView, <String>['8', '9']);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.data!.listView, <String>['8', '9', '10', '11', '12']);

        rxList.removeAt(0);
        expect(rxNew.value.data!.listView, <String>['9', '10', '11', '12']);

        rxList.remove(9);
        expect(rxNew.value.data!.listView, <String>['10', '11', '12']);

        rxList.clear();
        expect(rxNew.value.data!.listView, <String>[]);

        await rxList.dispose();

        expect(rxNew.disposed, true);
      });
    });
  });
}
