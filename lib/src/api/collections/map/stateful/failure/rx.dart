import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/map/stateful/failure/rx_impl.dart';

abstract class RxMapFailure<K, V, F>
    implements ObservableMapFailure<K, V, F>, RxMapStateful<ObservableMapFailure<K, V, F>, K, V, F> {
  factory RxMapFailure({
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapFailureImpl<K, V, F>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxMapFailure.failure({
    required final F failure,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapFailureImpl<K, V, F>.failure(
      failure: failure,
      factory: factory,
    );
  }

  set failure(final F failure);
}
