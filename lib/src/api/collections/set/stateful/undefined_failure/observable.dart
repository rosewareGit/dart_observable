import '../../../../../../dart_observable.dart';

abstract class ObservableSetUndefinedFailure<E, F>
    implements ObservableSetStateful<ObservableSetUndefinedFailure<E, F>, E, UndefinedFailure<F>> {
  ObservableSetUndefinedFailure<E2, F> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  });
}
