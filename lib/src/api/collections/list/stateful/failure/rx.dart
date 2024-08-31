import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/list/stateful/failure/rx_impl.dart';

abstract class RxListFailure<E, F>
    implements ObservableListFailure<E, F>, RxListStateful<ObservableListFailure<E, F>, E, F> {
  factory RxListFailure({
    final Iterable<E>? initial,
    final FactoryList<E>? factory,
  }) {
    return RxListFailureImpl<E, F>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxListFailure.failure({
    required final F failure,
    final FactoryList<E>? factory,
  }) {
    return RxListFailureImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }

  set failure(final F failure);
}
