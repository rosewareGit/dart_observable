import '../../../../../../dart_observable.dart';

abstract class ObservableListUndefined<E> implements ObservableListStateful<ObservableListUndefined<E>, E, Undefined> {
  ObservableListUndefined<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  });
}
