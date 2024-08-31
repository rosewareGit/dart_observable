import '../../../../../dart_observable.dart';

abstract class ObservableListStateful<Self extends ObservableListStateful<Self, E, S>, E, S>
    implements
        ObservableCollectionStateful<
            Self, // Self type
            ObservableListChange<E>, // the collection change type
            S, // The custom state
            ObservableListStatefulState<E, S> // The state type
            > {
  StateOf<int, S> get length;

  int? get lengthOrNull;

  E? operator [](final int position);

  Self changeFactory(final FactoryList<E> factory);

  Self filterItem(
    final bool Function(E item) predicate, {
    final FactoryList<E>? factory,
  });

  Observable<StateOf<E?, S>> rxItem(final int position);
}
