import '../../../../dart_observable.dart';

abstract interface class RxMapActions<K, V> {
  operator []=(final K key, final V value);

  ObservableMapChange<K, V>? add(final K key, final V value);

  ObservableMapChange<K, V>? addAll(final Map<K, V> other);

  ObservableMapChange<K, V>? clear();

  ObservableMapChange<K, V>? remove(final K key);

  ObservableMapChange<K, V>? removeWhere(final bool Function(K key, V value) predicate);
}
