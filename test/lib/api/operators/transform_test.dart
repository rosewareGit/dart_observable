import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('transformValue', () {
    test('Should return transformed value', () async {
      final Rx<int> rx = Rx<int>(0);
      final Observable<double> transformed = rx.transform<double>(
        initialProvider: (final Observable<int> source) {
          return source.value * 2.5;
        },
        onChanged: (
          final Observable<int> source,
          final Emitter<double> emitter,
        ) {
          emitter(source.value * 2.5);
        },
      );
      transformed.listen();

      expect(transformed.value, 0);
      rx.value = 1;
      expect(transformed.value, 2.5);
      rx.value = 2;
      expect(transformed.value, 5);
      rx.value = 3;
      expect(transformed.value, 7.5);

      expect(transformed.disposed, false);

      await rx.dispose();

      expect(rx.disposed, true);
      expect(transformed.disposed, true);
    });
  });
}
