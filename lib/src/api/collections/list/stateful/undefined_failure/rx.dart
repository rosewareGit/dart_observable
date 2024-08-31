import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/list/stateful/undefined_failure/rx_impl.dart';

abstract class RxListUndefinedFailure<E, F>
    implements
        ObservableListUndefinedFailure<E, F>,
        RxListStateful<ObservableListUndefinedFailure<E, F>, E, UndefinedFailure<F>> {
  factory RxListUndefinedFailure({
    final Iterable<E>? initial,
    final FactoryList<E>? factory,
  }) {
    return RxListUndefinedFailureImpl<E, F>.custom(
      initial: initial,
      factory: factory,
    );
  }

  factory RxListUndefinedFailure.failure(
    final F failure, {
    final FactoryList<E>? factory,
  }) {
    return RxListUndefinedFailureImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }

  set failure(final F failure);

  void setUndefined();
}
