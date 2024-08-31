import '../../../../../../dart_observable.dart';

abstract class ObservableSetUndefined<E> implements ObservableSetStateful<ObservableSetUndefined<E>, E, Undefined> {
  ObservableSetUndefined<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  });
}
