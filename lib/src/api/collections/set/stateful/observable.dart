import '../../../../../dart_observable.dart';

abstract class ObservableStatefulSet<E, S>
    implements
        ObservableCollectionStateful<
            ObservableSetChange<E>, // the collection type
            S, // The custom state
            ObservableStatefulSetState<E, S>> {
  int? get length;

  ObservableStatefulSet<E, S> changeFactory(final FactorySet<E> factory);

  bool contains(final E item);

  ObservableStatefulSet<E, S> filterItem(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  });

  ObservableStatefulSet<E2, S> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  });

  Observable<Either<E?, S>> rxItem(final bool Function(E item) predicate);
}
