import '../../../../../dart_observable.dart';

abstract class ObservableSetStateful<Self extends ObservableSetStateful<Self, E, S>, E, S>
    implements
        ObservableCollectionStateful<
            Self, // The collection type
            ObservableSetChange<E>, // the collection type
            S, // The custom state
            ObservableSetStatefulState<E, S>> {
  StateOf<int, S> get length;

  int? get lengthOrNull;

  Self changeFactory(final FactorySet<E> factory);

  bool contains(final E item);

  Self filterItem(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  });

  Observable<StateOf<E?, S>> rxItem(final bool Function(E item) predicate);
}
