import '../../../dart_observable.dart';

typedef ListUpdater<E, T> = void Function(
  ObservableList<E> state,
  T value,
  Emitter<List<E>> updater,
);

typedef MapUpdater<K, V, T> = void Function(
  ObservableMap<K, V> state,
  T value,
  Emitter<Map<K, V>> updater,
);

typedef SetUpdater<E, T> = void Function(
  ObservableSet<E> state,
  T value,
  Emitter<Set<E>> updater,
);

typedef StatefulListUpdater<E, S, T> = void Function(
  ObservableStatefulList<E, S> state,
  T value,
  Emitter<Either<List<E>, S>> updater,
);

typedef StatefulMapUpdater<K, V, S, T> = void Function(
  ObservableStatefulMap<K, V, S> state,
  T value,
  Emitter<Either<Map<K, V>, S>> updater,
);

typedef StatefulSetUpdater<E, S, T> = void Function(
  ObservableStatefulSet<E, S> state,
  T value,
  Emitter<Either<Set<E>, S>> updater,
);

abstract interface class ObservableTransforms<T> {
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

  ObservableStatefulList<E, S> statefulList<E, S>({
    required final StatefulListUpdater<E, S, T> transform,
    final FactoryList<E>? factory,
  });

  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapUpdater<K, V, S, T> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final StatefulSetUpdater<E, S, T> transform,
    final FactorySet<E>? factory,
  });
}
