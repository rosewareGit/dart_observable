import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableMap.filterObservableMapAsMap', () {
    test('Should update state when source change', () async {
      final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
        'a': 1,
        'b': 2,
        'c': 3,
      });

      rxMap['a'] = 2;
      rxMap.remove('b');

      final ObservableMap<String, int> filtered = rxMap.filterObservableMapAsMap((final String key, final int value) {
        return value > 1;
      });

      expect(filtered.length, 0);
      expect(filtered['a'], null);
      expect(filtered['b'], null);
      expect(filtered['c'], null);

      final Disposable listener = filtered.listen();

      expect(filtered['a'], 2, reason: 'Should be set');
      expect(filtered['b'], null, reason: 'Should be removed by key');
      expect(filtered['c'], 3, reason: 'Should be set');
      expect(filtered.length, 2, reason: 'No other keys');

      await listener.dispose();

      // Should not be updated now
      rxMap['a'] = 0;
      rxMap['b'] = 5;
      rxMap['c'] = 0;
      rxMap['d'] = 3;

      expect(filtered['a'], 2, reason: 'Should be the old value');
      expect(filtered['b'], null, reason: 'Should be removed');
      expect(filtered['c'], 3, reason: 'Should be the old value');
      expect(filtered['d'], null, reason: 'Should not be added');

      // Should be updated now
      filtered.listen();
      expect(filtered['a'], null, reason: 'Should be removed now');
      expect(filtered['b'], 5, reason: 'Should be added now');
      expect(filtered['c'], null, reason: 'Should be removed now');
      expect(filtered['d'], 3, reason: 'Should be added now');
    });

    test('Should dispose when source disposed', () async {
      final RxMap<String, int> rxMap = RxMap<String, int>(<String, int>{
        'a': 1,
        'b': 2,
        'c': 3,
      });

      final ObservableMap<String, int> filtered = rxMap.filterObservableMapAsMap((final String key, final int value) {
        return value > 1;
      });

      await rxMap.dispose();
      expect(filtered.disposed, true);
    });
  });
}
