import 'dart:async';

import 'package:dart_observable/dart_observable.dart';
import 'package:test/test.dart';

void main() {
  group('next', () {
    test('Should return next snapshot', () async {
      final Rx<int> rx = Rx<int>(0);
      Future<dynamic>.delayed(Duration(milliseconds: 2), () {
        rx.value = 1;
      });
      final int next = await rx.next();
      expect(next, 1);
    });

    test('Should return next snapshot with predicate', () async {
      final Rx<int> rx = Rx<int>(0);
      Future<dynamic>.delayed(Duration(milliseconds: 2), () {
        rx.value = 1;
      });
      Future<dynamic>.delayed(Duration(milliseconds: 3), () {
        rx.value = 2;
      });
      final int next = await rx.next(
        predicate: (final int value) {
          return value % 2 == 0;
        },
      );
      expect(next, 2);
    });

    test('Should return onTimeOutValue on time out', () async {
      final Rx<int> rx = Rx<int>(0);
      Future<dynamic>.delayed(Duration(milliseconds: 10), () {
        rx.value = 1;
      });
      final int next = await rx.next(
        timeout: Duration(milliseconds: 1),
        onTimeout: () {
          return 2;
        },
      );
      expect(next, 2);
    });

    test('Should throw on timeout without onTimeout', () async {
      final Rx<int> rx = Rx<int>(0);
      Future<dynamic>.delayed(Duration(milliseconds: 10), () {
        rx.value = 1;
      });

      rx.listen();

      expect(
        () async {
          await rx.next(
            timeout: Duration(milliseconds: 1),
          );
        },
        throwsA(isA<TimeoutException>()),
      );
    });

    test('Should throw disposed error when source is disposed before emitting', () {
      final Rx<int> rx = Rx<int>(0);
      Future<dynamic>.delayed(Duration(milliseconds: 10), () {
        rx.dispose();
      });
      expect(
        () async {
          await rx.next();
        },
        throwsA(isA<ObservableDisposedError>()),
      );
    });
  });
}
