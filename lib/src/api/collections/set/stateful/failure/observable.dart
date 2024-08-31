import '../../../../../../dart_observable.dart';

abstract class ObservableSetFailure<E, F> implements ObservableSetStateful<ObservableSetFailure<E, F>, E, F> {
  ObservableSetFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  });
}
