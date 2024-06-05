import '../../../../src/core/collections/map/factories/stream.dart';
import '../../../../src/core/collections/map/map.dart';
import 'observable.dart';
import 'update_action.dart';

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

  factory RxMap.fromStream({
    required final Stream<ObservableMapUpdateAction<K, V>> stream,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return ObservableMapFromStream<K, V>(
      stream: stream,
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

  set data(final Map<K, V> value);

  operator []=(final K key, final V value);

  void add(final K key, final V value);

  void addAll(final Map<K, V> other);

  void applyAction(final ObservableMapUpdateAction<K, V> action);

  void clear();

  void remove(final K key);

  void removeWhere(final bool Function(K key, V value) predicate);
}
