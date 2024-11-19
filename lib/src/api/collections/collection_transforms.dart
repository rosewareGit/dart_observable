import '../../../dart_observable.dart';

typedef ListChangeUpdater<E, C> = void Function(
  ObservableList<E> state,
  C change,
  Emitter<ObservableListUpdateAction<E>> updater,
);

typedef MapChangeUpdater<K, V, C> = void Function(
  ObservableMap<K, V> state,
  C change,
  Emitter<ObservableMapUpdateAction<K, V>> updater,
);

typedef SetChangeUpdater<E, C> = void Function(
  ObservableSet<E> state,
  C change,
  Emitter<ObservableSetUpdateAction<E>> updater,
);

typedef StatefulListChangeUpdater<E, S, C> = void Function(
  ObservableStatefulList<E, S> state,
  C change,
  Emitter<Either<ObservableListUpdateAction<E>, S>> updater,
);

typedef StatefulMapChangeUpdater<K, V, S, C> = void Function(
  ObservableStatefulMap<K, V, S> state,
  C change,
  Emitter<Either<ObservableMapUpdateAction<K, V>, S>> updater,
);

typedef StatefulSetChangeUpdater<E, S, C> = void Function(
  ObservableStatefulSet<E, S> state,
  C change,
  Emitter<Either<ObservableSetUpdateAction<E>, S>> updater,
);

abstract interface class ObservableCollectionTransforms<C> {
  ObservableList<E> list<E>({
    required final ListChangeUpdater<E, C> transform,
  });

  ObservableMap<K, V> map<K, V>({
    required final MapChangeUpdater<K, V, C> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E> set<E>({
    required final SetChangeUpdater<E, C> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  });

  ObservableStatefulList<E, S> statefulList<E, S>({
    required final StatefulListChangeUpdater<E, S, C> transform,
  });

  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapChangeUpdater<K, V, S, C> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final StatefulSetChangeUpdater<E, S, C> transform,
    final FactorySet<E>? factory,
  });
}
