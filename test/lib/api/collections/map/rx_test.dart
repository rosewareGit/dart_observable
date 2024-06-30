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
          'a': TestModel('a', 5),
          'b': TestModel('b', 3),
          'c': TestModel('c', 1),
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
  });
}
