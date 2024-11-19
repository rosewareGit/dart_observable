import '../../../../dart_observable.dart';
import '../../../core/collections/map/factories/merged.dart';
import '../../../core/collections/map/factories/stream.dart';

typedef MergeConflictResolver<K, V> = V? Function(K key, V current, ObservableItemChange<V?> conflict);

abstract interface class ObservableMap<K, V>
    implements ObservableCollection<ObservableMapState<K, V>, ObservableMapChange<K, V>> {
  factory ObservableMap.fromStream({
    required final Stream<ObservableMapUpdateAction<K, V>> stream,
    final Map<K, V>? Function(dynamic error)? onError,
    final FactoryMap<K, V>? factory,
    final Map<K, V>? initial,
  }) {
    return ObservableMapFromStream<K, V>(
      stream: stream,
      onError: onError,
      factory: factory,
      initial: initial,
    );
  }

  factory ObservableMap.just(
    final Map<K, V> value, {
    final FactoryMap<K, V>? factory,
  }) {
    return RxMap<K, V>(
      value,
      factory,
    );
  }

  factory ObservableMap.merged({
    required final Iterable<ObservableMap<K, V>> collections,
    final FactoryMap<K, V>? factory,
    final MergeConflictResolver<K, V>? conflictResolver,
  }) {
    return ObservableMapMerged<K, V>(
      collections: collections,
      factory: factory,
      conflictResolver: conflictResolver,
    );
  }

  int get length;

  V? operator [](final K key);

  ObservableMap<K, V> changeFactory(final FactoryMap<K, V> factory);

  bool containsKey(final K key);

  ObservableMap<K, V> filterItem(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  });

  ObservableMap<K, V2> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  });

  Observable<V?> rxItem(final K key);

  ObservableMap<K, V> sorted(final Comparator<V> comparator);

  List<V> toList();
}
