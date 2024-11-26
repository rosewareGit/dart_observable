import '../../../dart_observable.dart';

typedef ListChangeUpdater<E, C, T> = void Function(
  ObservableList<E> current,
  T state,
  C change,
  Emitter<ObservableListUpdateAction<E>> updater,
);

typedef MapChangeUpdater<K, V, C, T> = void Function(
  ObservableMap<K, V> current,
  T state,
  C change,
  Emitter<ObservableMapUpdateAction<K, V>> updater,
);

typedef SetChangeUpdater<E, C, T> = void Function(
  ObservableSet<E> current,
  T state,
  C change,
  Emitter<ObservableSetUpdateAction<E>> updater,
);

typedef StatefulListChangeUpdater<E, S, C, T> = void Function(
  ObservableStatefulList<E, S> current,
  T state,
  C change,
  Emitter<Either<ObservableListUpdateAction<E>, S>> updater,
);

typedef StatefulMapChangeUpdater<K, V, S, C, T> = void Function(
  ObservableStatefulMap<K, V, S> current,
  T state,
  C change,
  Emitter<Either<ObservableMapUpdateAction<K, V>, S>> updater,
);

typedef StatefulSetChangeUpdater<E, S, C, T> = void Function(
  ObservableStatefulSet<E, S> current,
  T state,
  C change,
  Emitter<Either<ObservableSetUpdateAction<E>, S>> updater,
);

abstract interface class ObservableCollectionTransforms<C, T> {
  ObservableList<E> list<E>({
    required final ListChangeUpdater<E, C, T> transform,
  });

  ObservableMap<K, V> map<K, V>({
    required final MapChangeUpdater<K, V, C, T> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E> set<E>({
    required final SetChangeUpdater<E, C, T> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  });

  ObservableStatefulList<E, S> statefulList<E, S>({
    required final StatefulListChangeUpdater<E, S, C, T> transform,
  });

  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapChangeUpdater<K, V, S, C, T> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final StatefulSetChangeUpdater<E, S, C, T> transform,
    final FactorySet<E>? factory,
  });
}
