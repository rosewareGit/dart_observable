import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('observable', () {
    group('disposed', () {
      test('Should be false by default', () {
        final Observable<int> rxInt = Observable<int>(0);
        expect(rxInt.disposed, false);
      });

      test('Should be true after dispose', () async {
        final Observable<int> rxInt = Observable<int>(0);
        await rxInt.dispose();
        expect(rxInt.disposed, true);
      });
    });

    group('previous', () {
      test('Should be null by default', () {
        final Observable<int> rxInt = Observable<int>(0);
        expect(rxInt.previous, null);
      });

      test('Should be null after dispose', () async {
        final Observable<int> rxInt = Observable<int>(0);
        await rxInt.dispose();
        expect(rxInt.previous, null);
      });

      test('Should be null after value change', () {
        final Rx<int> rxInt = Rx<int>(0);
        rxInt.value = 1;
        expect(rxInt.previous, 0);
      });

      test('Should be previous value after value change', () {
        final Rx<int> rxInt = Rx<int>(0);
        rxInt.value = 1;
        rxInt.value = 2;
        expect(rxInt.previous, 1);
      });
    });

    group('value', () {
      test('Should be initial value', () {
        final Observable<int> rxInt = Observable<int>(0);
        expect(rxInt.value, 0);
      });

      test('Should be changed value', () {
        final Rx<int> rxInt = Rx<int>(0);
        rxInt.value = 1;
        expect(rxInt.value, 1);
      });
    });

    group('dispose', () {
      test('Should dispose', () async {
        final Rx<int> rxInt = Rx<int>(0);
        await rxInt.dispose();
        expect(rxInt.disposed, true);
      });

      test('Should call workers', () async {
        final Rx<int> rxInt = Rx<int>(0);
        bool disposed = false;
        rxInt.addDisposeWorker(() async {
          disposed = true;
        });
        await rxInt.dispose();
        expect(disposed, true);
      });
    });

    group('listen', () {
      test('Should call listener', () {
        final Rx<int> rxInt = Rx<int>(0);
        bool called = false;
        rxInt.listen(
          onChange: (final Observable<int> source) {
            called = true;
          },
        );
        rxInt.value = 1;
        expect(called, true);
      });
    });
  });
}
