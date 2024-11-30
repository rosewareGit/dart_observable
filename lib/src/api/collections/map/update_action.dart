import '../../../../dart_observable.dart';

class ObservableMapUpdateAction<K, V> {
  final Map<K, V> addItems;
  final Iterable<K> removeKeys;
  final bool clear;

  ObservableMapUpdateAction({
    final Map<K, V>? addItems,
    final Iterable<K>? removeKeys,
    this.clear = false,
  })  : addItems = addItems ?? <K, V>{},
        removeKeys = removeKeys ?? <K>[];

  factory ObservableMapUpdateAction.fromChange(final ObservableMapChange<K, V> change) {
    return ObservableMapUpdateAction<K, V>(
      addItems: <K, V>{
        for (final MapEntry<K, V> entry in change.added.entries) entry.key: entry.value,
        for (final MapEntry<K, ObservableItemChange<V>> entry in change.updated.entries)
          entry.key: entry.value.newValue,
      },
      removeKeys: change.removed.keys,
    );
  }
}
