import 'dart:async';

import '../../dart_observable.dart';
import 'change_emitter.dart';

abstract interface class ChangeTrackingObservable<Self extends ChangeTrackingObservable<Self, T, C>, T, C>
    implements ChangeEmitter<T, C> {
  String get debugName;

  bool get disposed;

  bool get distinct;

  ObservableCollectionFlatMaps<C> get flatMapAs;

  T? get previous;

  ObservableState get state;

  ObservableCollectionTransforms<C> get transformAs;

  T get value;

  void addDisposeWorker(final FutureWorker worker);

  Observable<R> combineWith<R, T2>({
    required final Observable<T2> other,
    required final R Function(T value, T2 value2) combiner,
  });

  Observable<R> combineWith2<R, T2, T3>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final R Function(T value, T2 value2, T3 value3) combiner,
  });

  Observable<R> combineWith3<R, T2, T3, T4>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final Observable<T4> other3,
    required final R Function(T value, T2 value2, T3 value3, T4 value4) combiner,
  });

  Observable<R> combineWith4<R, T2, T3, T4, T5>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final Observable<T4> other3,
    required final Observable<T5> other4,
    required final R Function(T value, T2 value2, T3 value3, T4 value4, T5 value5) combiner,
  });

  Future<void> dispose();

  Observable<T?> filter(
    final bool Function(Self source) predicate,
  );

  Observable<T2> flatMap<T2>(
    final Observable<T2> Function(Self source) mapper,
  );

  Observable<T> handleError(
    final void Function(dynamic error, Emitter<T> emitter) handler, {
    final bool Function(dynamic error)? predicate,
  });

  Disposable listen({
    final Function(Self source)? onChange,
    final Function(dynamic error, StackTrace stack)? onError,
  });

  Observable<T2> map<T2>(
    final T2 Function(Self source) onChanged,
  );

  Future<T> next({
    final Duration? timeout,
    final bool Function(Self source)? predicate,
    final T Function()? onTimeout,
  });

  Disposable onActivityChanged({
    final void Function(Self source)? onActive,
    final void Function(Self source)? onInactive,
  });

  Observable<T2> transform<T2>({
    required final T2 Function(Self source) initialProvider,
    required final void Function(
      Self source,
      Emitter<T2> emitter,
    ) onChanged,
  });
}
