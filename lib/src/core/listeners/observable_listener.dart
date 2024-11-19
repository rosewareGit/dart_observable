import 'dart:async';

import '../../../dart_observable.dart';

class ObservableListener<T> implements Disposable {
  final FutureOr<void> Function(ObservableListener<T> disposable) _disposer;
  final void Function(T value)? _onChange;
  final void Function(dynamic error, StackTrace stack)? _onError;
  final Zone _zone;

  ObservableListener({
    required final FutureOr<void> Function(ObservableListener<T> disposable) disposer,
    final void Function(T value)? onChange,
    final void Function(dynamic error, StackTrace stack)? onError,
  }) : this._zoned(
          _forkZone(Zone.current, onError),
          disposer: disposer,
          onChange: onChange,
          onError: onError,
        );

  ObservableListener._zoned(
    this._zone, {
    required final void Function(ObservableListener<T> disposable) disposer,
    final void Function(T value)? onChange,
    final void Function(dynamic error, StackTrace stack)? onError,
  })  : _disposer = _registerDisposer<T>(_zone, disposer),
        _onChange = _registerHandler<T>(_zone, onChange),
        _onError = _registerErrorHandler(_zone, onError);

  @override
  FutureOr<void> dispose() {
    return _disposer(this);
  }

  void notify(final T value) {
    final void Function(T value)? handler = _onChange;
    if (handler == null) {
      return;
    }
    _zone.runUnaryGuarded(handler, value);
  }

  void notifyError(final Object error, final StackTrace stack) {
    final void Function(dynamic error, StackTrace stack)? errorHandler = _onError;
    if (errorHandler != null) {
      _zone.runBinaryGuarded(errorHandler, error, stack);
      return;
    }
    _zone.handleUncaughtError(error, stack);
  }

  static Zone _forkZone(
    final Zone current,
    final void Function(dynamic error, StackTrace stack)? onError,
  ) {
    return current.fork(
      specification: ZoneSpecification(
        handleUncaughtError: (
          final Zone self,
          final ZoneDelegate parent,
          final Zone zone,
          final Object error,
          final StackTrace stackTrace,
        ) {
          if (onError != null) {
            onError(error, stackTrace);
            return;
          }
          Error.throwWithStackTrace(error, stackTrace);
        },
      ),
    );
  }

  static _registerDisposer<T>(
    final Zone zone,
    final void Function(ObservableListener<T> disposable) disposer,
  ) {
    return zone.registerUnaryCallback(disposer);
  }

  static _registerErrorHandler(
    final Zone zone,
    final void Function(dynamic error, StackTrace stack)? onError,
  ) {
    if (onError == null) {
      return null;
    }
    return zone.registerBinaryCallback<dynamic, dynamic, StackTrace>(onError);
  }

  static _registerHandler<T>(
    final Zone zone,
    final void Function(T value)? handler,
  ) {
    if (handler == null) {
      return null;
    }
    return zone.registerUnaryCallback(handler);
  }
}
