import '../../../../dart_observable.dart';

abstract interface class ObservableList<E>
    implements ObservableCollection<ObservableListChange<E>, ObservableListState<E>> {
  int get length;

  E? operator [](final int position);

  ObservableList<E> changeFactory(final FactoryList<E> factory);

  ObservableList<E> filterItem(
    final bool Function(E item) predicate, {
    final FactoryList<E>? factory,
  });

  ObservableList<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  });

  Observable<E?> rxItem(final int position);
}
