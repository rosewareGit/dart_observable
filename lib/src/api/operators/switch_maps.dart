import '../../../dart_observable.dart';

abstract interface class ObservableSwitchMaps<T> {
  ObservableList<E> list<E>({
    required final ObservableList<E> Function(T value) mapper,
  });

  ObservableMap<K, V> map<K, V>({
    required final ObservableMap<K, V> Function(T value) mapper,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E> set<E>({
    required final ObservableSet<E> Function(T value) mapper,
    final FactorySet<E>? factory,
  });

  ObservableStatefulList<E, S> statefulList<E, S>({
    required final ObservableStatefulList<E, S> Function(T value) mapper,
  });

  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final ObservableStatefulMap<K, V, S> Function(T value) mapper,
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final ObservableStatefulSet<E, S> Function(T value) mapper,
    final FactorySet<E>? factory,
  });
}
