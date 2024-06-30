import '../../../../dart_observable.dart';

abstract interface class ObservableList<E>
    implements ObservableCollection<E, ObservableListChange<E>, ObservableListState<E>> {
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

  ObservableListResult<E, F> mapAsListResult<F>({
    final ObservableListResultUpdateAction<E, F> Function(
      ObservableListChange<E> change,
      ObservableList<E> source,
    )? changeHandler,
    final FactoryList<E>? factory,
  });

  ObservableMap<K, E> mapAsMap<K>({
    required final K Function(E item) keyProvider,
    final FactoryMap<K, E>? factory,
  });

  ObservableMapResult<K, E, F> mapAsMapResult<K, F>({
    required final K Function(E item) keyProvider,
    final FactoryMap<K, E>? factory,
    final ObservableMapResultUpdateAction<K, E, F> Function(
      ObservableMapChange<K, E> change,
      ObservableList<E> source,
    )? changeHandler,
  });

  ObservableSet<E> mapAsSet({
    final FactorySet<E>? factory,
  });

  ObservableSetResult<E, F> mapAsSetResult<F>({
    final ObservableSetResultUpdateAction<E, F> Function(
      ObservableSetChange<E> change,
      ObservableList<E> source,
    )? changeHandler,
    final FactorySet<E>? factory,
  });

  Observable<E?> rxItem(final int position);
}
