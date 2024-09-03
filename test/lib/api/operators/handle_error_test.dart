import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:dart_observable/src/guarded.dart';
import 'package:test/test.dart';

void main() {
  group('handle error', () {
    test('Should catch from stream', () async {
      final StreamController<int> streamController = StreamController<int>.broadcast(sync: true);
      final Observable<int> fromStream = Observable<int>.fromStream(
        stream: streamController.stream,
        initial: 0,
      );

      final List<dynamic> errors = <dynamic>[];

      final List<dynamic> catchedBaseErrors = <dynamic>[];
      runGuarded(
        () {
          fromStream.listen();
        },
        onError: (final dynamic e, final StackTrace s) {
          catchedBaseErrors.add(e);
        },
      );

      final Observable<int> catching = fromStream.map((final int value) {
        if (value == 2) {
          throw 'errorMap';
        }
        return value * 2;
      }).handleError((final dynamic error, final Emitter<int> emit) {
        errors.add(error);
      });

      catching.listen();

      streamController.add(1);
      expect(fromStream.value, 1);
      expect(catching.value, 2);

      streamController.addError('error');

      streamController.add(2);
      streamController.addError('error2');

      expect(errors.length, 3);
      expect(fromStream.value, 2);
      expect(catching.value, 2);

      streamController.addError('error3');

      streamController.add(3);
      expect(catching.value, 6);

      expect(catchedBaseErrors.length, 3);
      expect(errors[0], 'error');
      expect(errors[1], 'errorMap');
      expect(errors[2], 'error2');
      expect(errors[3], 'error3');

      expect(fromStream.disposed, false);

      await streamController.close();

      expect(fromStream.disposed, true);
    });

    test('Should not throw and dispatch error', () async {
      final Rx<int> rx = Rx<int>(1);

      final List<dynamic> errors = <dynamic>[];
      final List<dynamic> errors2 = <dynamic>[];
      int mapper(final int value) {
        if (value % 2 == 0) {
          throw ArgumentError(value);
        }
        return value;
      }

      void errorHandler(final dynamic error, final Emitter<int> emit) {
        errors.add(error);
      }

      void errorHandler2(final dynamic error, final Emitter<int> emit) {
        errors2.add(error);
      }

      final Observable<int> base = rx //
          .map(mapper);

      final Observable<int> guarded = base.handleError(errorHandler);
      final Observable<int> guarded2 = base.handleError(errorHandler2);

      bool baseCatched = false;
      runGuarded(
        () {
          base.listen();
        },
        onError: (final dynamic error, final StackTrace stack) {
          baseCatched = true;
        },
      );

      guarded.listen();
      guarded2.listen();

      expect(guarded.value, 1);
      expect(guarded2.value, 1);

      rx.value = 2;

      expect(baseCatched, true);
      expect(guarded.value, 1);
      expect(errors.length, 1);
      expect(errors2.length, 1);

      // Should not cancel subscription on error
      rx.value = 3;
      expect(guarded.value, 3);
      expect(guarded2.value, 3);
    });

    test('Should handle errors from futures', () async {
      Future<int?> futureError() async {
        throw 'error';
      }

      final Observable<int?> rxFuture = Observable<int?>.fromFuture(
        future: futureError(),
        initial: null,
      );

      bool futureErrorCatched = false;
      rxFuture.listen(
        onError: (final dynamic error, final StackTrace stack) {
          futureErrorCatched = true;
        },
      );
      final List<dynamic> errors = <dynamic>[];
      final Observable<int?> guarded = rxFuture.handleError((final dynamic error, final Emitter<int?> emit) {
        errors.add(error);
      });

      guarded.listen();

      await Future<dynamic>.delayed(Duration.zero);

      expect(errors.length, 1);
      expect(errors[0], 'error');
      expect(futureErrorCatched, true);
      expect(guarded.disposed, true);
    });

    test('Should handle lazy future errors', () async {
      Future<int?> futureError() async {
        throw 'error';
      }

      final Observable<int?> rxFuture = Observable<int?>.fromFuture(
        futureProvider: () {
          return futureError();
        },
        initial: null,
      );

      bool futureErrorCatched = false;
      rxFuture.listen(
        onError: (final dynamic error, final StackTrace stack) {
          futureErrorCatched = true;
        },
      );
      final List<dynamic> errors = <dynamic>[];
      final Observable<int?> guarded = rxFuture.handleError((final dynamic error, final Emitter<int?> emit) {
        errors.add(error);
      });

      guarded.listen();

      await Future<dynamic>.delayed(Duration.zero);

      expect(errors.length, 1);
      expect(errors[0], 'error');
      expect(futureErrorCatched, true);
    });

    test('Should pass unhandled exceptions down the chain', () async {
      final Rx<int> rx = Rx<int>(0);

      int mapper(final int value) {
        if (value == 1) {
          throw StateError('1');
        }
        if (value == 2) {
          throw ArgumentError('2');
        }
        return value;
      }

      final Observable<String> base = rx //
          .map(mapper)
          .map((final int value) {
        if (value == 3) {
          throw '3';
        }
        return value.toString();
      });

      final List<dynamic> errorsGuarded = <dynamic>[];
      final List<dynamic> errorsGuardedNested = <dynamic>[];
      final Observable<String> guarded = base.handleError(
        (final dynamic error, final Emitter<String> emit) {
          errorsGuarded.add(error);
        },
        predicate: (final dynamic error) {
          return error is ArgumentError;
        },
      );

      final Observable<String> guardedNested = guarded.handleError(
        (final dynamic error, final Emitter<String> emit) {
          errorsGuardedNested.add(error);
        },
      );

      guardedNested.listen();
      rx.value = 1;
      rx.value = 2;
      rx.value = 3;
      rx.value = 4;

      expect(guardedNested.value, '4');
      expect(errorsGuarded.length, 1);
      expect(errorsGuardedNested.length, 2);
    });

    test('Should dispatch error to listen', () {
      final Rx<int> rx = Rx<int>(0);

      final List<dynamic> guardErrors = <dynamic>[];
      final List<dynamic> subscriptionErrors = <dynamic>[];

      final Observable<double> guarded = rx.map((final int value) {
        if (value == 1) {
          throw ArgumentError('1');
        }
        if (value == 3) {
          throw 'error-3';
        }
        return value * 2.0;
      }).handleError(
        (final dynamic error, final Emitter<double> emit) {
          emit(1);
          guardErrors.add(error);
        },
        predicate: (final dynamic error) {
          return error is ArgumentError;
        },
      );

      final List<double> values = <double>[];
      guarded.listen(
        onChange: (final double value) {
          values.add(value);
        },
        onError: (final dynamic error, final StackTrace stack) {
          subscriptionErrors.add(error);
        },
      );

      expect(guardErrors.length, 0);
      expect(subscriptionErrors.length, 0);

      rx.value = 1;
      expect(guarded.value, 1.0);

      expect(guardErrors.length, 1);
      expect(subscriptionErrors.length, 0);

      rx.value = 2;
      expect(guarded.value, 4);
      rx.value = 3;
      expect(guarded.value, 4);

      expect(guardErrors.length, 1);
      expect(subscriptionErrors.length, 1);
    });

    test('Should dispose when source disposed', () async {
      final Rx<int> rx = Rx<int>(0);

      final Observable<int> handled = rx.handleError((final _, final __) {});

      expect(handled.disposed, false);

      await rx.dispose();

      expect(rx.disposed, true);
      expect(handled.disposed, true);
    });
  });
}
