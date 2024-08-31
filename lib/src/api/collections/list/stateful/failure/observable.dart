import '../../../../../../dart_observable.dart';

abstract class ObservableListFailure<E, F> implements ObservableListStateful<ObservableListFailure<E, F>, E, F> {
  ObservableListFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  });
}
