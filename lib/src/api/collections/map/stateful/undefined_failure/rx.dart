import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/map/stateful/undefined_failure/rx_impl.dart';

abstract class RxMapUndefinedFailure<K, V, F>
    implements
        ObservableMapUndefinedFailure<K, V, F>,
        RxMapStateful<ObservableMapUndefinedFailure<K, V, F>, K, V, UndefinedFailure<F>> {
  factory RxMapUndefinedFailure({
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapUndefinedFailureImpl<K, V, F>.custom(
      initial: initial,
      factory: factory,
    );
  }

  factory RxMapUndefinedFailure.failure(
    final F failure, {
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapUndefinedFailureImpl<K, V, F>.failure(
      failure: failure,
      factory: factory,
    );
  }

  set failure(final F failure);

  void setUndefined();
}
