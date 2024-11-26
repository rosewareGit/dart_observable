import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxMap', () {
    group('value', () {
      test('Should return an unmodifiable map', () {
        final RxMap<String, int> map = RxMap<String, int>(<String, int>{
          'a': 1,
          'b': 2,
        });

        final Map<String, int> value = map.value;

        expect(value.length, 2);
        expect(value['a'], 1);
        expect(value['b'], 2);

        expect(() => value['a'] = 3, throwsUnsupportedError);
        expect(() => value['c'] = 3, throwsUnsupportedError);
        expect(() => value.remove('a'), throwsUnsupportedError);
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