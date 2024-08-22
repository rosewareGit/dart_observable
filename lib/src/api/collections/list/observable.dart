import '../../../../dart_observable.dart';

abstract interface class ObservableList<E>
    implements ObservableCollection<ObservableList<E>, E, ObservableListChange<E>, ObservableListState<E>> {
  factory ObservableList([
    final Iterable<E>? initial,
    final List<E> Function(Iterable<E>? items)? factory,
  ]) {
    return RxList<E>(initial, factory);
  }

  int get length;

  E? operator [](final int position);

  ObservableList<E> filterList({
    required final bool Function(E item) predicate,
    final FactoryList<E>? factory,
  });

  ObservableList<E2> flatMapList<E2>({
    required final ObservableList<E2>? Function(
      ObservableListChange<E> change,
      ObservableList<E> source,
    ) sourceProvider,
    final FactoryList<E2>? factory,
  });

  ObservableSet<E> mapAsSet({
    final FactorySet<E>? factory,
  });

  Observable<E?> rxItem(final int position);
}
