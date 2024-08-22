import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/list/stateful/failure/list.dart';

abstract class RxListResult<E, F>
    implements ObservableListFailure<E, F>, RxListStateful<ObservableListFailure<E, F>, E, F> {
  factory RxListResult({
    final Iterable<E>? initial,
    final FactoryList<E>? factory,
  }) {
    return RxListFailureImpl<E, F>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxListResult.failure({
    required final F failure,
    final FactoryList<E>? factory,
  }) {
    return RxListFailureImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }
}
