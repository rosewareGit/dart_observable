import 'dart:async';

import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';

mixin OperatorNext<Self extends ChangeTrackingObservable<Self, T, C>, T, C>
    implements ChangeTrackingObservable<Self, T, C> {
  @override
  Future<T> next({
    final Duration? timeout,
    final bool Function(Self source)? predicate,
    final T Function()? onTimeout,
  }) {
    final Completer<T> completer = Completer<T>();
    final Disposable disposable = listen(
      onChange: (final Self source) {
        if (completer.isCompleted) {
          return;
        }
        if (predicate == null || predicate(source)) {
          completer.complete(source.value);
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
