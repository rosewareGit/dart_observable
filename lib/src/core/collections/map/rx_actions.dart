import '../../../../dart_observable.dart';
import '../../../api/collections/map/rx_actions.dart';

mixin RxMapActionsImpl<K, V> implements RxMapActions<K, V> {
  Map<K, V> get data;

  @override
  void operator []=(final K key, final V value) {
    applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(addItems: <K, V>{key: value}),
    );
  }

  @override
  ObservableMapChange<K, V>? add(final K key, final V value) {
    return addAll(<K, V>{key: value});
  }

  @override
  ObservableMapChange<K, V>? addAll(final Map<K, V> other) {
    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(addItems: other),
    );
  }

  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action);

  @override
  ObservableMapChange<K, V>? clear() {
    final Map<K, V> data = this.data;
    if (data.isEmpty) {
      return null;
    }

    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(removeKeys: data.keys),
    );
  }

  @override
  ObservableMapChange<K, V>? remove(final K key) {
    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(removeKeys: <K>{key}),
    );
  }

  @override
  ObservableMapChange<K, V>? removeWhere(final bool Function(K key, V value) predicate) {
    final Set<K> removed = <K>{};
    final Map<K, V> data = this.data;
    for (final MapEntry<K, V> entry in data.entries) {
      if (predicate(entry.key, entry.value)) {
        removed.add(entry.key);
      }
    }
    if (removed.isEmpty) {
      return null;
    }

    return applyMapUpdateAction(
      ObservableMapUpdateAction<K, V>(removeKeys: removed),
    );
  }

  @override
  ObservableMapChange<K, V>? setData(final Map<K, V> data) {
    final Map<K, V> current = this.data;
    final ObservableMapChange<K, V> change = ObservableMapChange<K, V>.fromDiff(current, data);
    if (change.isEmpty) {
      return null;
    }

    return applyMapUpdateAction(ObservableMapUpdateAction<K, V>.fromChange(change));
  }
}
