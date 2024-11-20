import 'dart:async';

import '../../dart_observable.dart';

typedef Emitter<T> = void Function(T value);
typedef FactoryMap<K, V> = Map<K, V> Function(Map<K, V>? items);
typedef FactorySet<T> = Set<T> Function(Iterable<T>? items);
typedef FutureWorker = FutureOr<void> Function();

abstract interface class Observable<T> {
  factory Observable.combineLatest({
    required final Iterable<Observable<dynamic>> observables,
    required final T Function() combiner,
    final bool distinct = true,
  }) {
    return Rx<T>.combineLatest(
      observables: observables,
      combiner: combiner,
      distinct: distinct,
    );
  }

  factory Observable.fromFuture({
    required final T initial,
    final Future<T>? future,
    final Future<T> Function()? futureProvider,
    final bool distinct = true,
  }) {
    return Rx<T>.fromFuture(
      future: future,
      futureProvider: futureProvider,
      initial: initial,
      distinct: distinct,
    );
  }

  factory Observable.fromStream({
    required final Stream<T> stream,
    required final T initial,
    final bool distinct = true,
  }) {
    return Rx<T>.fromStream(
      stream: stream,
      initial: initial,
      distinct: distinct,
    );
  }

  factory Observable.just(
    final T value, {
    final bool distinct = true,
  }) {
    return Rx<T>(
      value,
      distinct: distinct,
    );
  }

  String get debugName;

  bool get disposed;

  bool get distinct;

  T? get previous;

  ObservableState get state;

  ObservableSwitchMaps<T> get switchMapAs;

  ObservableTransforms<T> get transformAs;

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

  Observable<T?> filter(final bool Function(T value) predicate);

  Observable<T> handleError(
    final void Function(dynamic error, Emitter<T> emitter) handler, {
    final bool Function(dynamic error)? predicate,
  });

  Disposable listen({
    final Function(T value)? onChange,
    final Function(dynamic error, StackTrace stack)? onError,
  });

  Observable<T2> map<T2>(
    final T2 Function(T value) onChanged,
  );

  Future<T> next({
    final Duration? timeout,
    final bool Function(T value)? predicate,
    final T Function()? onTimeout,
  });

  Disposable onActivityChanged({
    final void Function(T value)? onActive,
    final void Function(T value)? onInactive,
  });

  Observable<T2> switchMap<T2>(
    final Observable<T2> Function(T value) mapper,
  );

  Observable<T2> transform<T2>({
    required final T2 Function(T value) initialProvider,
    required final void Function(
      T value,
      Emitter<T2> emitter,
    ) onChanged,
  });
}

enum ObservableState {
  active,
  inactive,
  disposed,
}
