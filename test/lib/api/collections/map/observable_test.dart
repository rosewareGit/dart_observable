import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

class TestModel {
  final String key;
  final int value;

  TestModel(this.key, this.value);
}

void main() {
  group('ObservableMap', () {
    group('sorted', () {
      test('Should return sorted values', () {
        final RxMap<String, TestModel> rxSortedMap = RxMap<String, TestModel>.sorted(
          comparator: (final TestModel a, final TestModel b) => a.value.compareTo(b.value),
          keyProvider: (final TestModel value) => value.key,
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

    group('operator []', () {
      test('should return the value for the given key', () {
        final ObservableMap<String, int> map = ObservableMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        expect(map['a'], 1);
        expect(map['b'], 2);
        expect(map['c'], null);
      });
    });

    group('rxItem', () {
      test('Should map initial state', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        final Observable<int?> b = rxMap.rxItem('b');
        final Observable<int?> c = rxMap.rxItem('c');

        expect(a.value, 1);
        expect(b.value, 2);
        expect(c.value, null);
      });

      test('Should only emit update after listen', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });
        final Observable<int?> a = rxMap.rxItem('a');

        // Observable cold by default
        rxMap['a'] = 3;

        expect(a.value, 1);
        final Disposable listener = a.listen();
        expect(a.value, 3);
        await listener.dispose();

        // Should not be updated now
        rxMap['a'] = 4;
        rxMap['a'] = 5;
        expect(a.value, 3);

        // Should be updated now
        a.listen();
        expect(a.value, 5);
      });

      test('Should update value for key', () {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        a.listen();

        expect(a.value, 1);

        rxMap['a'] = 3;
        expect(a.value, 3);

        rxMap.remove('a');
        expect(a.value, null);

        rxMap['a'] = 4;
        expect(a.value, 4);
      });

      test('Should dispose when source disposed', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        a.listen();
        expect(a.value, 1);
        await rxMap.dispose();
        expect(a.disposed, true);
      });

      test('Should dispose when listener disposed', () async {
        final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
          'a': 1,
        });
        final Observable<int?> a = rxMap.rxItem('a');
        final Disposable sub = a.listen();
        expect(a.value, 1);
        await sub.dispose();
      });
    });
  });
}
