import '../../../../../dart_observable.dart';

enum CustomState {
  loading,
  loginError,
  parsingError,
  success,
  secondaryList,
}

abstract class ObservableStatefulList<E, S>
    implements
        ObservableCollectionStateful<
            ObservableListChange<E>, // the collection change type
            S, // The custom state
            ObservableStatefulListState<E, S> // The state type
            > {
  int? get length;

  E? operator [](final int position);

  ObservableStatefulList<E, S> changeFactory(final FactoryList<E> factory);

  ObservableStatefulList<E, S> filterItem(
    final bool Function(E item) predicate, {
    final FactoryList<E>? factory,
  });

  ObservableStatefulList<E2, S> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  });

  Observable<Either<E?, S>> rxItem(final int position);
}
