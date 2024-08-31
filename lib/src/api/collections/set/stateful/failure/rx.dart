import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/set/stateful/failure/rx_impl.dart';

abstract class RxSetFailure<E, F>
    implements ObservableSetFailure<E, F>, RxSetStateful<ObservableSetFailure<E, F>, E, F> {
  factory RxSetFailure({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return RxSetFailureImpl<E, F>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxSetFailure.failure({
    required final F failure,
    final FactorySet<E>? factory,
  }) {
    return RxSetFailureImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }
}
