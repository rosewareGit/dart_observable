import '../../../../dart_observable.dart';
import '../../../../src/core/collections/map/map.dart';

abstract interface class RxMap<K, V> implements ObservableMap<K, V> {
  factory RxMap([
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  ]) {
    return RxMapImpl<K, V>(
      initial: initial,
      factory: factory,
    );
  }

  factory RxMap.sorted({
    required final Comparator<V> comparator,
    final Map<K, V>? initial,
  }) {
    return RxMapImpl<K, V>.sorted(
      comparator: comparator,
      initial: initial,
    );
  }

  operator []=(final K key, final V value);

  ObservableMapChange<K, V>? add(final K key, final V value);

  ObservableMapChange<K, V>? addAll(final Map<K, V> other);

  ObservableMapChange<K, V>? applyAction(final ObservableMapUpdateAction<K, V> action);

  ObservableMapChange<K, V>? clear();

  ObservableMapChange<K, V>? remove(final K key);

  ObservableMapChange<K, V>? removeWhere(final bool Function(K key, V value) predicate);

  ObservableMapChange<K, V>? setData(final Map<K, V> value);
}
