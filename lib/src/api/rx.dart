import '../core/rx/_impl.dart';
import '../core/rx/factories/combine_latest_n.dart';
import '../core/rx/factories/future.dart';
import '../core/rx/factories/future_n.dart';
import '../core/rx/factories/stream.dart';
import '../core/rx/factories/stream_n.dart';
import 'observable.dart';
import 'observable_n.dart';

abstract interface class Rx<T> implements Observable<T> {
  factory Rx(
    final T value, {
    final bool distinct = true,
  }) {
    return RxImpl<T>(
      value,
      distinct: distinct,
    );
  }

  factory Rx.combineLatest({
    required final Iterable<Observable<dynamic>> observables,
    required final T Function() combiner,
    final bool distinct = true,
  }) {
    return ObservableCombineLatestN<T>(
      observables: observables,
      combiner: combiner,
      distinct: distinct,
    );
  }

  factory Rx.fromFuture({
    required final T initial,
    required final Future<T> Function() futureProvider,
    final bool distinct = true,
  }) {
    return FutureObservable<T>(
      initial: initial,
      futureProvider: futureProvider,
      distinct: distinct,
    );
  }

  factory Rx.fromStream({
    required final Stream<T> stream,
    required final T initial,
    final bool distinct = true,
  }) {
    return StreamObservable<T>(
      stream: stream,
      initial: initial,
      distinct: distinct,
    );
  }

  set value(final T value);

  void dispatchError({
    required final dynamic error,
    final StackTrace? stack,
  });
}

abstract interface class Rxn<T> extends Rx<T?> implements ObservableN<T> {
  factory Rxn({
    final T? value,
    final bool distinct = true,
  }) {
    return RxnImpl<T>(
      value: value,
      distinct: distinct,
    );
  }

  factory Rxn.fromFuture({
    final Future<T?>? future,
    final Future<T?> Function()? futureProvider,
    final bool distinct = true,
  }) {
    return FutureObservableN<T>(
      future: future,
      futureProvider: futureProvider,
      distinct: distinct,
    );
  }

  factory Rxn.fromStream({
    required final Stream<T?> stream,
    final bool distinct = true,
  }) {
    return StreamObservableN<T>(
      stream: stream,
      distinct: distinct,
    );
  }
}
