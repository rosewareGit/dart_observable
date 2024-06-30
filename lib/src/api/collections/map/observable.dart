import '../../../../dart_observable.dart';
import '../../../core/collections/map/factories/stream.dart';

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
    final Map<K, V>? initial,
  }) {
    return RxMap<K, V>.sorted(
      comparator: comparator,
      initial: initial,
    );
  }

  factory ObservableMap.fromStream({
    required final Stream<ObservableMapUpdateAction<K, V>> stream,
    final FactoryMap<K,V>? factory,
  }) {
    return ObservableMapFromStream<K, V>(
      stream: stream,
      factory: factory,
    );
  }

  int get length;

  V? operator [](final K key);

  ObservableMap<K, V> changeFactory(final FactoryMap<K, V> factory);

  bool containsKey(final K key);

  ObservableMap<K, V> filterMap(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  });

  ObservableMap<K, V2> mapMap<V2>({
    required final V2 Function(K key, V value) valueMapper,
    final FactoryMap<K, V2>? factory,
  });

  Observable<V?> rxItem(final K key);

  List<V> toList();
}
