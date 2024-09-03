import 'dart:async';

import '../../../../dart_observable.dart';

mixin OperatorNext<T> implements Observable<T> {
  @override
  Future<T> next({
    final Duration? timeout,
    final bool Function(T value)? predicate,
    final T Function()? onTimeout,
  }) {
    final Completer<T> completer = Completer<T>();
    final Disposable disposable = listen(
      onChange: (final T value) {
        if (completer.isCompleted) {
          return;
        }
        if (predicate == null || predicate(value)) {
          completer.complete(value);
        }
      },
    );

    addDisposeWorker(() {
      if (completer.isCompleted == false) {
        completer.completeError(ObservableDisposedError());
      }
    });

    return completer.future
        .timeout(
      timeout ?? const Duration(seconds: 30),
      onTimeout: onTimeout == null
          ? null
          : () {
              return onTimeout();
            },
    )
        .whenComplete(
      () {
        disposable.dispose();
      },
    );
  }
}
