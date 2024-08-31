import '../../../../../../dart_observable.dart';

abstract class ObservableListUndefinedFailure<E, F>
    implements ObservableListStateful<ObservableListUndefinedFailure<E, F>, E, UndefinedFailure<F>> {
  ObservableListUndefinedFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  });
}
