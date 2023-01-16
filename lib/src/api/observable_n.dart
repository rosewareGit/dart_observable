import 'dart:async';

import '../../dart_observable.dart';

abstract interface class ObservableN<T> implements Observable<T?> {
  factory ObservableN({
    final bool distinct = true,
  }) {
    return Rxn<T>(
      distinct: distinct,
    );
  }

  factory ObservableN.fromStream({
    required final Stream<T?> stream,
    final bool distinct = true,
  }) {
    return Rxn<T>.fromStream(
      stream: stream,
      distinct: distinct,
    );
  }

  factory ObservableN.fromFuture({
    final Future<T>? future,
    final Future<T> Function()? futureProvider,
    final bool distinct = true,
  }) {
    return Rxn<T>.fromFuture(
      future: future,
      futureProvider: futureProvider,
      distinct: distinct,
    );
  }
}
