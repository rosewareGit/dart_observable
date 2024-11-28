import '../../../../dart_observable.dart';

mixin MapUpdateActionHandler<K, V> {
  ObservableMapChange<K, V> applyActionAndComputeChange({
    required final Map<K, V> data,
    required final ObservableMapUpdateAction<K, V> action,
  }) {
    final Map<K, V> added = <K, V>{};
    final Map<K, V> removed = <K, V>{};
    final Map<K, ObservableItemChange<V>> updated = <K, ObservableItemChange<V>>{};

    final Map<K, V> addItems = action.addItems;
    final List<K> removeKeys = <K>[];

    if (action.clear) {
      removeKeys.addAll(data.keys);
    } else {
      removeKeys.addAll(action.removeKeys);
    }

    for (final K key in removeKeys) {
      final V? current = data[key];
      if (current != null) {
        removed[key] = current;
      }
    }

    data.removeWhere((final K key, final V value) => removeKeys.contains(key));

    for (final MapEntry<K, V> entry in addItems.entries) {
      final V? current = data[entry.key];
      if (current == null) {
        added[entry.key] = entry.value;
        data[entry.key] = entry.value;
      } else if (current != entry.value) {
        updated[entry.key] = ObservableItemChange<V>(
          oldValue: current,
          newValue: entry.value,
        );
        data[entry.key] = entry.value;
      }
    }

    return ObservableMapChange<K, V>(
      added: added,
      removed: removed,
      updated: updated,
    );
  }
}
