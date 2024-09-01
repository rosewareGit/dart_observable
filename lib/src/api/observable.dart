import 'dart:async';

import '../../dart_observable.dart';
import 'change_tracking_observable.dart';

typedef Emitter<T> = void Function(T value);
typedef FactoryList<T> = List<T> Function(Iterable<T>? items);
typedef FactoryMap<K, V> = Map<K, V> Function(Map<K, V>? items);
typedef FactorySet<T> = Set<T> Function(Iterable<T>? items);
typedef FutureWorker = FutureOr<void> Function();

abstract interface class Observable<T> implements ChangeTrackingObservable<Observable<T>, T, T> {
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
}

enum ObservableState {
  active,
  inactive,
  disposed,
}
