import '../../../dart_observable.dart';

abstract interface class ObservableCollectionSwitchMaps<C> {
  ObservableList<E> list<E>({
    required final ObservableList<E>? Function(C change) mapper,
  });

  ObservableMap<K, V> map<K, V>({
    required final ObservableMap<K, V>? Function(C change) mapper,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E> set<E>({
    required final ObservableSet<E>? Function(C change) mapper,
    final FactorySet<E>? factory,
  });

  ObservableStatefulList<E, S> statefulList<E, S>({
    required final ObservableStatefulList<E, S>? Function(C change) mapper,
  });

  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final ObservableStatefulMap<K, V, S>? Function(C change) mapper,
    final FactoryMap<K, V>? factory,
  });

  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final ObservableStatefulSet<E, S>? Function(C change) mapper,
    final FactorySet<E>? factory,
  });
}
