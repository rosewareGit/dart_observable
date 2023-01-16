import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable/src/api/collections/list/update_action.dart';
import 'package:test/test.dart';

void main() {
  group('RxList', () {
    group('[]=', () {
      test('Should set the item at the specified index', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList[0] = 4;
        expect(rxList[0], 4);
      });

      test('Should add the item if the index is greater than the length of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList[10] = 4;
        expect(rxList[3], 4);
      });
    });

    group('add', () {
      test('Should add the item to the end of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.add(4);
        expect(rxList[3], 4);
      });
    });

    group('addAll', () {
      test('Should add all the items to the end of the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.addAll(<int>[4, 5]);
        expect(rxList[3], 4);
        expect(rxList[4], 5);
      });
    });

    group('applyAction', () {
      test('Should apply add action to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.applyAction(
          ObservableListUpdateAction<int>.add(
            <MapEntry<int?, Iterable<int>>>[
              MapEntry<int?, Iterable<int>>(0, <int>[4, 5]),
              MapEntry<int?, Iterable<int>>(1, <int>[6, 7]),
              MapEntry<int?, Iterable<int>>(10, <int>[10]),
            ],
          ),
        );

        expect(rxList.value.listView, <int>[4, 5, 1, 6, 7, 2, 3, 10]);
      });

      test('Should apply remove action to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.applyAction(
          ObservableListUpdateAction<int>.remove(
            <int>{1, 2},
          ),
        );

        expect(rxList.value.listView, <int>[1]);
      });

      test('Should apply update action to the list', () {
        final RxList<int> rxList = RxList<int>(<int>[1, 2, 3]);
        rxList.applyAction(
          ObservableListUpdateAction<int>.update(
            <int, int>{
              0: 4,
              1: 5,
              5: 10,
            },
          ),
        );

        expect(rxList.value.listView, <int>[4, 5, 3, 10]);
      });
    });
  });
}
