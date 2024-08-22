import '../../../../../dart_observable.dart';

abstract class ObservableListStateful<Self extends ObservableListStateful<Self, E, S>, E, S>
    implements
        ObservableCollectionStateful<
            Self, // Self type
            E, // The type of the elements
            ObservableListChange<E>, // the collection change type
            S, // The custom state
            ObservableListStatefulState<E, S> // The state type
            > {
  StateOf<int, S> get length;

  int? get lengthOrNull;

  E? operator [](final int position);

  Observable<StateOf<E?, S>> rxItem(final int position);

// T changeFactory(final FactoryList<E> factory);
}
