import '../../../../dart_observable.dart';

export 'transforms/lists.dart';
export 'transforms/maps.dart';
export 'transforms/sets.dart';

typedef ListUpdater<E, C> = void Function(
  ObservableList<E> state,
  C change,
  Emitter<ObservableListUpdateAction<E>> updater,
);

typedef MapUpdater<K, V, C> = void Function(
  ObservableMap<K, V> state,
  C change,
  Emitter<ObservableMapUpdateAction<K, V>> updater,
);

typedef SetUpdater<E, C> = void Function(
  ObservableSet<E> state,
  C change,
  Emitter<ObservableSetUpdateAction<E>> updater,
);

abstract interface class ObservableCollectionTransforms<C> {
  OperatorsTransformLists<C> get lists;

  OperatorsTransformMaps<C> get maps;

  OperatorsTransformSets<C> get sets;

  ObservableList<E> list<E>({
    required final ListUpdater<E, C> transform,
    final FactoryList<E>? factory,
  });

  ObservableMap<K, V> map<K, V>({
    required final MapUpdater<K, V, C> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E> set<E>({
    required final SetUpdater<E, C> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  });
}
