import '../../../../../dart_observable.dart';

abstract class ObservableSetStateful<Self extends ObservableSetStateful<Self, E, S>, E, S>
    implements
        ObservableCollectionStateful<
            Self, // The collection type
            E, // The type of the elements
            ObservableSetChange<E>, // the collection type
            S, // The custom state
            ObservableSetStatefulState<E, S>> {
  StateOf<int, S> get length;

  int? get lengthOrNull;

  bool contains(final E item);

  Observable<StateOf<E?, S>> rxItem(final bool Function(E item) predicate);

// T changeFactory(final FactorySet<E> factory);
}
