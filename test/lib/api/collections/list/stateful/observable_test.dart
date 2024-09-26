import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableStatefulList', () {
    group('length', () {
      test('should return the length of the list', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        expect(list.length, 3);

        list.add(4);
        expect(list.length, 4);

        list.setState('custom');
        expect(list.length, null);
      });
    });

    group('[]', () {
      test('should return the item at the given index', () {
        final RxStatefulList<int, String> list = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        expect(list[0], 1);
        expect(list[1], 2);
        expect(list[2], 3);

        list.add(4);
        expect(list[3], 4);

        list.setState('custom');
        expect(list[0], null);
        expect(list[1], null);
        expect(list[2], null);
        expect(list[3], null);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the list', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3]);
        final ObservableStatefulList<int, String> rxNew = rxList.changeFactory((final Iterable<int>? items) {
          return List<int>.of(items ?? <int>[]);
        });

        rxNew.listen();

        expect(rxNew.value.leftOrThrow.listView, <int>[1, 2, 3]);

        rxList.add(4);

        expect(rxNew.value.leftOrThrow.listView, <int>[1, 2, 3, 4]);

        rxList.setState('custom');

        expect(rxNew.value.leftOrNull, null);

        rxList.add(5);

        expect(rxNew.value.leftOrThrow.listView, <int>[5]);

        await rxList.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the list', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<int, String> rxNew = rxList.filterItem((final int item) => item.isOdd);

        rxNew.listen();
        expect(rxNew.value.leftOrThrow.listView, <int>[1, 3, 5]);

        rxList.add(6);
        expect(rxNew.value.leftOrThrow.listView, <int>[1, 3, 5]);

        rxList.add(7);
        expect(rxNew.value.leftOrThrow.listView, <int>[1, 3, 5, 7]);

        rxList.remove(3);
        expect(rxNew.value.leftOrThrow.listView, <int>[1, 5, 7]);

        rxList.setState('custom');
        expect(rxNew.value.leftOrNull, null);

        rxList.add(8);
        expect(rxNew.value.leftOrThrow.listView, <int>[]);

        rxList.add(9);
        expect(rxNew.value.leftOrThrow.listView, <int>[9]);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow.listView, <int>[9, 11]);

        rxList.clear();
        expect(rxNew.value.leftOrThrow.listView, <int>[]);

        await rxList.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item at the given index', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final Observable<Either<int?, String>> rxItem = rxList.rxItem(2);

        rxItem.listen();
        expect(rxItem.value.leftOrNull, 3);

        rxList.add(6);
        expect(rxItem.value.leftOrNull, 3);

        rxList.add(7);
        expect(rxItem.value.leftOrNull, 3);

        rxList.remove(3);
        expect(rxItem.value.leftOrNull, 4);

        rxList.removeAt(2);
        expect(rxItem.value.leftOrNull, 5);

        rxList.setState('custom');
        expect(rxItem.value.leftOrNull, null);
        expect(rxItem.value.rightOrNull, 'custom');

        rxList.add(8);
        expect(rxItem.value.leftOrNull, null);

        rxList.add(9);
        expect(rxItem.value.leftOrNull, null);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxItem.value.leftOrNull, 10);

        rxList.clear();
        expect(rxItem.value.leftOrNull, null);

        await rxList.dispose();

        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map data change', () async {
        final RxStatefulList<int, String> rxList = RxStatefulList<int, String>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableStatefulList<String, String> rxNew = rxList.mapItem((final int item) => item.toString());

        rxNew.listen();
        expect(rxNew.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5']);

        rxList.add(6);
        expect(rxNew.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5', '6']);

        rxList.add(7);
        expect(rxNew.value.leftOrThrow.listView, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxList.remove(3);
        expect(rxNew.value.leftOrThrow.listView, <String>['1', '2', '4', '5', '6', '7']);

        rxList.setState('custom');
        expect(rxNew.value.leftOrNull, null);
        expect(rxNew.value.rightOrNull, 'custom');

        rxList.add(8);
        expect(rxNew.value.leftOrThrow.listView, <String>['8']);

        rxList.add(9);
        expect(rxNew.value.leftOrThrow.listView, <String>['8', '9']);

        rxList.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.leftOrThrow.listView, <String>['8', '9', '10', '11', '12']);

        rxList.removeAt(0);
        expect(rxNew.value.leftOrThrow.listView, <String>['9', '10', '11', '12']);

        rxList.remove(9);
        expect(rxNew.value.leftOrThrow.listView, <String>['10', '11', '12']);

        rxList.clear();
        expect(rxNew.value.leftOrThrow.listView, <String>[]);

        await rxList.dispose();

        expect(rxNew.disposed, true);
      });
    });
  });
}
