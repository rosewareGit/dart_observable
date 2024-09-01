import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('Observable.combineWith', () {
    test('should combine two observables', () {
      final Observable<int> observable1 = Rx<int>(1);
      final Observable<int> observable2 = Rx<int>(2);

      final Observable<int> combined = observable1.combineWith<int, int>(
        other: observable2,
        combiner: (final int value1, final int value2) => value1 + value2,
      );

      expect(combined.value, 3);
    });

    test('should update when the first observable changes', () {
      final Rx<int> observable1 = Rx<int>(1);
      final Observable<int> observable2 = Rx<int>(2);

      final Observable<int> combined = observable1.combineWith<int, int>(
        other: observable2,
        combiner: (final int value1, final int value2) => value1 + value2,
      );

      combined.listen();

      observable1.value = 3;

      expect(combined.value, 5);
    });

    test('should update when the second observable changes', () {
      final Observable<int> observable1 = Rx<int>(1);
      final Rx<int> observable2 = Rx<int>(2);

      final Observable<int> combined = observable1.combineWith<int, int>(
        other: observable2,
        combiner: (final int value1, final int value2) => value1 + value2,
      );

      combined.listen();

      observable2.value = 3;

      expect(combined.value, 4);
    });

    test('Should dispose only when all observables are disposed', () async {
      final Observable<int> observable1 = Rx<int>(1);
      final Observable<int> observable2 = Rx<int>(2);

      final Observable<int> combined = observable1.combineWith<int, int>(
        other: observable2,
        combiner: (final int value1, final int value2) => value1 + value2,
      );

      final List<int> values = <int>[];
      final Disposable listener = combined.listen(
        onChange: (final Observable<int> source) {
          values.add(source.value);
        },
      );

      await observable1.dispose();
      expect(combined.disposed, false);

      await observable2.dispose();
      expect(combined.disposed, true);

      await listener.dispose();
    });

    test('Should dispatch error from sources', () {
      final Rx<int> observable1 = Rx<int>(1);
      final Rx<int> observable2 = Rx<int>(2);

      final Observable<int> combined = observable1.combineWith<int, int>(
        other: observable2,
        combiner: (final int value1, final int value2) => value1 + value2,
      );

      final List<dynamic> errors = <Object>[];
      final Disposable listener = combined.listen(
        onChange: (final Observable<int> source) {
        },
        onError: (final dynamic error, final StackTrace stack) {
          errors.add(error);
        },
      );

      observable1.dispatchError(error: StateError('Error 1'));
      observable2.dispatchError(error: StateError('Error 2'));

      expect((errors[0] as StateError).message,  'Error 1');
      expect((errors[1] as StateError).message,  'Error 2');

      listener.dispose();
    });
  });
}
