import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableSetUndefined', () {
    group('length', () {
      test('should return the length of the set', () {
        final RxSetUndefined<int> set = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        expect(set.length.data, 3);

        set.add(4);
        expect(set.length.data, 4);

        set.setUndefined();
        expect(set.length.data, null);
        expect(set.length.custom, Undefined());
      });
    });

    group('lengthOrNull', () {
      test('should return the length of the set', () {
        final RxSetUndefined<int> set = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        expect(set.lengthOrNull, 3);

        set.add(4);
        expect(set.lengthOrNull, 4);

        set.setUndefined();
        expect(set.lengthOrNull, null);
      });
    });

    group('changeFactory', () {
      test('should change the factory of the set', () async {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3]);
        final ObservableSetUndefined<int> rxNew = rxSet.changeFactory((final Iterable<int>? items) {
          return Set<int>.of(items ?? <int>[]);
        });

        rxNew.listen();

        expect(rxNew.value.data!.setView, <int>[1, 2, 3]);

        rxSet.add(4);

        expect(rxNew.value.data!.setView, <int>[1, 2, 3, 4]);

        rxSet.setUndefined();

        expect(rxNew.value.data, null);

        rxSet.add(5);

        expect(rxNew.value.data!.setView, <int>[5]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('filterItem', () {
      test('should filter the items of the set', () async {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableSetUndefined<int> rxNew = rxSet.filterItem((final int item) => item.isOdd);

        rxNew.listen();
        expect(rxNew.value.data!.setView, <int>[1, 3, 5]);

        rxSet.add(6);
        expect(rxNew.value.data!.setView, <int>[1, 3, 5]);

        rxSet.add(7);
        expect(rxNew.value.data!.setView, <int>[1, 3, 5, 7]);

        rxSet.remove(3);
        expect(rxNew.value.data!.setView, <int>[1, 5, 7]);

        rxSet.setUndefined();
        expect(rxNew.value.data, null);

        rxSet.add(8);
        expect(rxNew.value.data!.setView, <int>[]);

        rxSet.add(9);
        expect(rxNew.value.data!.setView, <int>[9]);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.data!.setView, <int>[9, 11]);

        rxSet.clear();
        expect(rxNew.value.data!.setView, <int>[]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });

    group('rxItem', () {
      test('should return the item at the given index', () async {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3, 4, 5]);
        final Observable<StateOf<int?, Undefined>> rxItem = rxSet.rxItem((final int item) => item == 2);

        rxItem.listen();
        expect(rxItem.value.data, 2);

        rxSet.add(7);
        expect(rxItem.value.data, 2);

        rxSet.remove(2);
        expect(rxItem.value.data, null);

        rxSet.add(2);
        expect(rxItem.value.data, 2);

        rxSet.setUndefined();
        expect(rxItem.value.data, null);
        expect(rxItem.value.custom, Undefined());

        rxSet.addAll(<int>[2, 3, 4]);
        expect(rxItem.value.data, 2);

        rxSet.clear();
        expect(rxItem.value.data, null);

        await rxSet.dispose();

        expect(rxItem.disposed, true);
      });
    });

    group('mapItem', () {
      test('Should map data change', () async {
        final RxSetUndefined<int> rxSet = RxSetUndefined<int>(initial: <int>[1, 2, 3, 4, 5]);
        final ObservableSetUndefined<String> rxNew = rxSet.mapItem((final int item) => item.toString());

        rxNew.listen();
        expect(rxNew.value.data!.setView, <String>['1', '2', '3', '4', '5']);

        rxSet.add(6);
        expect(rxNew.value.data!.setView, <String>['1', '2', '3', '4', '5', '6']);

        rxSet.add(7);
        expect(rxNew.value.data!.setView, <String>['1', '2', '3', '4', '5', '6', '7']);

        rxSet.remove(3);
        expect(rxNew.value.data!.setView, <String>['1', '2', '4', '5', '6', '7']);

        rxSet.setUndefined();
        expect(rxNew.value.data, null);
        expect(rxNew.value.custom, Undefined());

        rxSet.add(8);
        expect(rxNew.value.data!.setView, <String>['8']);

        rxSet.add(9);
        expect(rxNew.value.data!.setView, <String>['8', '9']);

        rxSet.addAll(<int>[10, 11, 12]);
        expect(rxNew.value.data!.setView, <String>['8', '9', '10', '11', '12']);

        rxSet.remove(8);
        expect(rxNew.value.data!.setView, <String>['9', '10', '11', '12']);

        rxSet.remove(9);
        expect(rxNew.value.data!.setView, <String>['10', '11', '12']);

        rxSet.clear();
        expect(rxNew.value.data!.setView, <String>[]);

        await rxSet.dispose();

        expect(rxNew.disposed, true);
      });
    });
  });
}
