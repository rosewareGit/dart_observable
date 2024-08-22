import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/set/stateful/failure/set.dart';

abstract class RxSetResult<E, F>
    implements ObservableSetFailure<E, F>, RxSetStateful<ObservableSetFailure<E, F>, E, F> {
  factory RxSetResult({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return RxSetFailureImpl<E, F>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxSetResult.failure({
    required final F failure,
    final FactorySet<E>? factory,
  }) {
    return RxSetFailureImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }
}
