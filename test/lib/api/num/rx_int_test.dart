import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('RxInt', () {
    test('operator +', () async {
      int updateCount = 0;
      final RxInt rxInt = RxInt(0);
      rxInt.listen(
        onChange: (final Observable<int> source) {
          ++updateCount;
        },
      );
      expect(updateCount, 0);

      rxInt + 1;

      expect(updateCount, 1);
      expect(rxInt.value, 1);
      rxInt.value = 4;
      expect(rxInt.value, 4);
      expect(updateCount, 2);
    });
  });
}
