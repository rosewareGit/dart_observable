import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/set/stateful/undefined_failure/set.dart';

abstract class RxSetUndefinedFailure<E, F>
    implements
        ObservableSetUndefinedFailure<E, F>,
        RxSetStateful<ObservableSetUndefinedFailure<E, F>, E, UndefinedFailure<F>> {
  factory RxSetUndefinedFailure({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedFailureImpl<E, F>.custom(
      initial: initial,
      factory: factory,
    );
  }

  factory RxSetUndefinedFailure.failure(
    final F failure, {
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedFailureImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }
}
