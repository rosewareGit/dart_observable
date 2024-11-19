class ObservableMapUpdateAction<K, V> {
  final Map<K, V> addItems;
  final Iterable<K> removeKeys;

  ObservableMapUpdateAction({
    final Map<K, V>? addItems,
    final Iterable<K>? removeKeys,
  })  : addItems = addItems ?? <K, V>{},
        removeKeys = removeKeys ?? <K>[];
}
