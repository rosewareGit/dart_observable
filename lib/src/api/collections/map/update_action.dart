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
}
