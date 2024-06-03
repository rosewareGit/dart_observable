import '../item_change.dart';

class ObservableMapChange<K, V> {
  final Map<K, V> added;
  final Map<K, ObservableItemChange<V>> updated;
  final Map<K, V> removed;

  ObservableMapChange({
    final Map<K, V>? added,
    final Map<K, ObservableItemChange<V>>? updated,
    final Map<K, V>? removed,
  })  : added = added ?? <K, V>{},
        updated = updated ?? <K, ObservableItemChange<V>>{},
        removed = removed ?? <K, V>{};

  factory ObservableMapChange.fromDiff(
    final Map<K, V> previous,
    final Map<K, V> current,
  ) {
    final Map<K, V> added = <K, V>{};
    final Map<K, V> removed = <K, V>{};
    final Map<K, ObservableItemChange<V>> updated = <K, ObservableItemChange<V>>{};

    for (final MapEntry<K, V> entry in current.entries) {
      final V? previousValue = previous[entry.key];
      if (previousValue == null) {
        added[entry.key] = entry.value;
      } else if (previousValue != entry.value) {
        updated[entry.key] = ObservableItemChange<V>(
          oldValue: previousValue,
          newValue: entry.value,
        );
      }
    }

    for (final MapEntry<K, V> entry in previous.entries) {
      if (!current.containsKey(entry.key)) {
        removed[entry.key] = entry.value;
      }
    }

    return ObservableMapChange<K, V>(
      added: added,
      updated: updated,
      removed: removed,
    );
  }

  bool get isEmpty => added.isEmpty && updated.isEmpty && removed.isEmpty;

  static ObservableMapChange<K, V> fromAction<K, V>({
    required final Map<K, V> state,
    required final Map<K, V> addItems,
    required final Iterable<K> removeItems,
  }) {
    final Map<K, V> added = <K, V>{};
    final Map<K, V> removed = <K, V>{};
    final Map<K, ObservableItemChange<V>> updated = <K, ObservableItemChange<V>>{};

    for (final K key in removeItems) {
      final V? current = state[key];
      if (current != null) {
        removed[key] = current;
        state.remove(key);
      }
    }

    for (final MapEntry<K, V> entry in addItems.entries) {
      final V? current = state[entry.key];
      if (current == null) {
        added[entry.key] = entry.value;
        state[entry.key] = entry.value;
      } else if (current != entry.value) {
        updated[entry.key] = ObservableItemChange<V>(
          oldValue: current,
          newValue: entry.value,
        );
        state[entry.key] = entry.value;
      }
    }
    return ObservableMapChange<K, V>(
      added: added,
      updated: updated,
      removed: removed,
    );
  }
}
