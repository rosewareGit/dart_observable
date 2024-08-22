import '../../../../dart_observable.dart';
import '../../../api/collections/map/rx_actions.dart';

mixin RxMapActionsImpl<K, V> implements RxMapActions<K, V> {
  Map<K, V>? get data;

  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action);

  @override
  void operator []=(final K key, final V value) {
    applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{},
        addItems: <K, V>{key: value},
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? add(final K key, final V value) {
    return addAll(<K, V>{key: value});
  }

  @override
  ObservableMapChange<K, V>? addAll(final Map<K, V> other) {
    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{},
        addItems: other,
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? clear() {
    final Map<K, V>? data = this.data;
    if (data == null || data.isEmpty) {
      return null;
    }

    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: data.keys.toSet(),
        addItems: <K, V>{},
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? remove(final K key) {
    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{key},
        addItems: <K, V>{},
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? removeWhere(final bool Function(K key, V value) predicate) {
    final Set<K> removed = <K>{};
    final Map<K, V>? data = this.data;
    if (data == null) {
      return null;
    }
    for (final MapEntry<K, V> entry in data.entries) {
      if (predicate(entry.key, entry.value)) {
        removed.add(entry.key);
      }
    }
    if (removed.isEmpty) {
      return null;
    }
    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: removed,
        addItems: <K, V>{},
      ),
    );
  }
}
