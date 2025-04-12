import 'dart:async';

import '../../dart_observable.dart';

typedef Emitter<T> = void Function(T value);
typedef FactoryMap<K, V> = Map<K, V> Function(Map<K, V>? items);
typedef FactorySet<T> = Set<T> Function(Iterable<T>? items);
typedef FutureWorker = FutureOr<void> Function();

abstract interface class Observable<T> implements Disposable {
  /// Creates a new [Observable] from the [observables].
  /// On any update from any of the [observables], the [combiner] function is called to update the value.
  ///  - [combiner] should return the value in sync.
  ///  - [distinct] determines whether the [Observable] should emit the same value multiple times.
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

  /// Creates a new [Observable] from the future returned by [futureProvider].
  /// The [initial] value is used until the [future] completes.
  /// - [distinct] determines whether the [Observable] should emit the same value multiple times.
  factory Observable.fromFuture({
    required final T initial,
    required final Future<T> Function() futureProvider,
    final bool distinct = true,
  }) {
    return Rx<T>.fromFuture(
      futureProvider: futureProvider,
      initial: initial,
      distinct: distinct,
    );
  }

  /// Creates a new [Observable] from the [stream].
  /// The [initial] value is used until the [stream] emits a value.
  /// - [distinct] determines whether the [Observable] should emit the same value multiple times.
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

  /// Creates a new [Observable] from the [value].
  factory Observable.just(final T value) {
    return Rx<T>(value);
  }

  /// Each observable has a unique identifier that assigned at creation.
  String get debugName;

  /// Returns the number of update events emitted by the [Observable].
  int get updateCount;

  /// Returns whether the [Observable] has been disposed.
  bool get disposed;

  /// Returns whether the [Observable] emits distinct values.
  /// If [distinct] is `true`, the [Observable] will not emit the same value multiple times.
  bool get distinct;

  /// Returns the previous value emitted by the [Observable].
  T? get previous;

  /// Returns the current state of the [Observable].
  /// - [ObservableState.active] if the [Observable] has listeners.
  /// - [ObservableState.inactive] if the [Observable] has no listeners.
  /// - [ObservableState.disposed] if the [Observable] has been disposed.
  ObservableState get state;

  ObservableSwitchMaps<T> get switchMapAs;

  ObservableTransforms<T> get transformAs;

  /// Returns the current value of the [Observable].
  T get value;

  /// Adds a worker that will be called when the [Observable] is disposed.
  /// The observable is marked as disposed after all workers are completed.
  void addDisposeWorker(final FutureWorker worker);

  /// Combines the [Observable] with another [Observable] of type [T2].
  /// The [combiner] function is called on any update from either this or the [other] [Observable].
  /// - [combiner] should return the value in sync.
  Observable<R> combineWith<R, T2>({
    required final Observable<T2> other,
    required final R Function(T value, T2 value2) combiner,
  });

  /// Combines the [Observable] with two other [Observable]s of type [T2] and [T3].
  /// The [combiner] function is called on any update from either this, the [other], or the [other2].
  Observable<R> combineWith2<R, T2, T3>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final R Function(T value, T2 value2, T3 value3) combiner,
  });

  /// Combines the [Observable] with three other [Observable]s of type [T2], [T3], and [T4].
  Observable<R> combineWith3<R, T2, T3, T4>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final Observable<T4> other3,
    required final R Function(T value, T2 value2, T3 value3, T4 value4) combiner,
  });

  /// Combines the [Observable] with four other [Observable]s of type [T2], [T3], [T4], and [T5].
  Observable<R> combineWith4<R, T2, T3, T4, T5>({
    required final Observable<T2> other,
    required final Observable<T3> other2,
    required final Observable<T4> other3,
    required final Observable<T5> other4,
    required final R Function(T value, T2 value2, T3 value3, T4 value4, T5 value5) combiner,
  });

  /// Dispose the [Observable], releasing all resources.
  /// The [Observable] will no longer emit values.
  /// A disposed [Observable] cannot be reused.
  @override
  Future<void> dispose();

  /// Creates a new [Observable] that emits the value if the [predicate] returns `true`.
  /// If the [predicate] returns `false`, the [Observable] will ignore that value.
  /// When the source [Observable] is disposed, the new [Observable] is also disposed.
  Observable<T?> filter(final bool Function(T value) predicate);

  /// Creates a new [Observable] which catches any errors emitted by the upstream.
  /// The [handler] function is called when an error is emitted.
  /// If the [predicate] function is provided, the [handler] function is only called if the [predicate] returns `true`.
  /// The handler function can emit any value based on the error.
  /// When the source [Observable] is disposed, the new [Observable] is also disposed.
  Observable<T> handleError(
    final void Function(dynamic error, Emitter<T> emitter) handler, {
    final bool Function(dynamic error)? predicate,
  });

  /// Registers a listener to the [Observable].
  /// The [onChange] function is called when the [Observable] emits a new value.
  /// The [onError] function is called when the [Observable] emits an error.
  /// When the [Observable] is disposed, the listener is also disposed.
  Disposable listen({
    final Function(T value)? onChange,
    final Function(dynamic error, StackTrace stack)? onError,
  });

  /// Creates a new [Observable] that emits the value transformed by the [onChanged] function.
  /// When the source [Observable] is disposed, the new [Observable] is also disposed.
  Observable<T2> map<T2>(final T2 Function(T value) onChanged);

  /// Waits for the [Observable] to emit a value that satisfies the [predicate] function.
  /// [timeout] duration is the maximum time to wait for the value.
  /// If the [timeout] duration is reached, and [onTimeout] is not provided, the [Future] will complete with an error.
  /// if the [onTimeout] function is provided, the [Future] will complete with the value returned by the [onTimeout] function.
  Future<T> next({
    final Duration? timeout,
    final bool Function(T value)? predicate,
    final T Function()? onTimeout,
  });

  /// Registers an activity listener to the [Observable].
  /// The [onActive] function is called when the [Observable] registers the first listener.
  /// The [onInactive] function is called when the [Observable] dispose the last listener.
  /// [onActive] is called on register if the [Observable] has listeners.
  /// [onInactive] is called on register if the [Observable] has no listeners, but was active before.
  Disposable onActivityChanged({
    final void Function(T value)? onActive,
    final void Function(T value)? onInactive,
  });

  /// Creates a new [Observable] that listens to the [Observable] provided by the [mapper] function.
  /// The [mapper] function is called each time the source [Observable] emits a value.
  /// The previous internal [Observable] is disposed when the new [Observable] is provided by the [mapper] function.
  /// When the source [Observable] is disposed, the new [Observable] is also disposed.
  Observable<T2> switchMap<T2>(final Observable<T2> Function(T value) mapper);

  /// Creates a new [Observable] which value is updated by the Emitter in the [onChanged] function.
  ///   - The Emitter can ignore or emit multiple values from one change.
  /// The [onChanged] function is called when the source [Observable] emits a new value.
  /// When the source [Observable] is disposed, the new [Observable] is also disposed.
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
