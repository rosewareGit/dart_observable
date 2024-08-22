import 'dart:async';

import '../../../dart_observable.dart';
import '../../api/change_tracking_observable.dart';

class ObservableListener<S extends ChangeTrackingObservable<S, T, C>, T, C> implements Disposable {
  final FutureOr<void> Function(ObservableListener<S, T, C> disposable) _disposer;
  final void Function(S source)? _onChange;
  final void Function(dynamic error, StackTrace stack)? _onError;
  final Zone _zone;

  ObservableListener({
    required final FutureOr<void> Function(ObservableListener<S, T, C> disposable) disposer,
    final void Function(S source)? onChange,
    final void Function(dynamic error, StackTrace stack)? onError,
  }) : this._zoned(
          _forkZone(Zone.current, onError),
          disposer: disposer,
          onChange: onChange,
          onError: onError,
        );

  ObservableListener._zoned(
    this._zone, {
    required final void Function(ObservableListener<S, T, C> disposable) disposer,
    final void Function(S source)? onChange,
    final void Function(dynamic error, StackTrace stack)? onError,
  })  : _disposer = _registerDisposer<S, T, C>(_zone, disposer),
        _onChange = _registerHandler<S, T, C>(_zone, onChange),
        _onError = _registerErrorHandler(_zone, onError);

  @override
  Future<void> dispose() async {
    await _disposer(this);
  }

  void notify(final S source) {
    final void Function(S source)? handler = _onChange;
    if (handler == null) {
      return;
    }
    _zone.runUnaryGuarded(handler, source);
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

  static _registerDisposer<S extends ChangeTrackingObservable<S, T, C>, T, C>(
    final Zone zone,
    final void Function(ObservableListener<S, T, C> disposable) disposer,
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

  static _registerHandler<S extends ChangeTrackingObservable<S, T, C>, T, C>(
    final Zone zone,
    final void Function(S source)? handler,
  ) {
    if (handler == null) {
      return null;
    }
    return zone.registerUnaryCallback(handler);
  }
}
