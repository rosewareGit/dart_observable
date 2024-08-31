import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

import 'observable_test.dart';

void main() {
  group('RxMap', () {
    group('sorted', () {
      test('Should return sorted values', () {
        final RxMap<String, TestModel> rxSortedMap = RxMap<String, TestModel>.sorted(
          comparator: (final TestModel a, final TestModel b) => a.value.compareTo(b.value),
        );

        expect(rxSortedMap.toList(), <TestModel>[]);

        rxSortedMap.addAll(<String, TestModel>{
          'a': TestModel(5),
          'b': TestModel(3),
          'c': TestModel(1),
        });

        final List<TestModel> list = rxSortedMap.toList();
        expect(list[0].value, 1);
        expect(list[1].value, 3);
        expect(list[2].value, 5);

        rxSortedMap.remove('c');

        final List<TestModel> list2 = rxSortedMap.toList();
        expect(list2[0].value, 3);
        expect(list2[1].value, 5);
      });
    });

    group('setData', () {
      test('Should set data', () {
        final RxMap<String, int> rxMap = RxMap<String, int>();
        final ObservableMapChange<String, int>? change = rxMap.setData(<String, int>{
          'a': 5,
          'b': 3,
          'c': 1,
        });

        expect(change!.added.length, 3);
        expect(change.removed.length, 0);
        expect(change.updated.length, 0);

        expect(rxMap['a'], 5);
        expect(rxMap['b'], 3);
        expect(rxMap['c'], 1);

        final ObservableMapChange<String, int>? change2 = rxMap.setData(<String, int>{
          'a': 5,
          'b': 3,
          'c': 1,
        });

        expect(change2, null);

        final ObservableMapChange<String, int>? change3 = rxMap.setData(<String, int>{
          'a': 1,
          'b': 3,
        });

        expect(change3!.added.length, 0);
        expect(change3.removed.length, 1);
        expect(change3.updated.length, 1);
        expect(change3.updated['a']!.oldValue, 5);
        expect(change3.updated['a']!.newValue, 1);

        expect(rxMap['a'], 1);
        expect(rxMap['b'], 3);
        expect(rxMap['c'], null);
      });
    });
  });
}
