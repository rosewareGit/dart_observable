import '../../../dart_observable.dart';

export 'transforms/lists.dart';
export 'transforms/maps.dart';
export 'transforms/sets.dart';

typedef ListUpdater<E, T> = void Function(
  ObservableList<E> state,
  T value,
  Emitter<ObservableListUpdateAction<E>> updater,
);

typedef MapUpdater<K, V, T> = void Function(
  ObservableMap<K, V> state,
  T value,
  Emitter<ObservableMapUpdateAction<K, V>> updater,
);

typedef SetUpdater<E, T> = void Function(
  ObservableSet<E> state,
  T value,
  Emitter<ObservableSetUpdateAction<E>> updater,
);

abstract interface class ObservableTransforms<T> {
  OperatorsTransformLists<T> get lists;

  OperatorsTransformMaps<T> get maps;

  OperatorsTransformSets<T> get sets;

  ObservableList<E> list<E>({
    required final ListUpdater<E, T> transform,
    final FactoryList<E>? factory,
  });

  ObservableMap<K, V> map<K, V>({
    required final MapUpdater<K, V, T> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E> set<E>({
    required final SetUpdater<E, T> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  });
}
