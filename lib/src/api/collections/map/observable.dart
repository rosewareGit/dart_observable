import '../../../../dart_observable.dart';

abstract interface class ObservableMap<K, V>
    implements ObservableCollection<K, ObservableMapChange<K, V>, ObservableMapState<K, V>> {
  factory ObservableMap([
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  ]) {
    return RxMap<K, V>(initial, factory);
  }

  factory ObservableMap.sorted({
    required final Comparator<V> comparator,
    required final K Function(V value) keyProvider,
    final Map<K, V>? initial,
  }) {
    return RxMap<K, V>.sorted(
      comparator: comparator,
      keyProvider: keyProvider,
      initial: initial,
    );
  }

  int get length;

  V? operator [](final K key);


  bool containsKey(final K key);

  ObservableMap<K, V> filterObservableMapAsMap(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  });

  ObservableMap<K, V2> mapObservableMapAsMap<V2>({
    required final V2 Function(K key, V value) valueMapper,
    final FactoryMap<K, V2>? factory,
  });

  Observable<V?> rxItem(final K key);

  List<V> toList();
}
