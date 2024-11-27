class ObservableListUpdateAction<E> {
  final Iterable<E> addItems;
  final Map<int, Iterable<E>> insertAt;
  final Map<int, E> updateItems;
  final Set<int> removeItems;
  final bool clear;

  ObservableListUpdateAction({
    final Iterable<E>? addItems,
    final Map<int, Iterable<E>>? insertAt,
    final Map<int, E>? updateItems,
    final Set<int>? removeAtPositions,
    this.clear = false,
  })  : addItems = addItems ?? <E>[],
        insertAt = insertAt ?? <int, Iterable<E>>{},
        updateItems = updateItems ?? <int, E>{},
        removeItems = removeAtPositions ?? <int>{};

  bool get isEmpty =>
      addItems.isEmpty && insertAt.isEmpty && updateItems.isEmpty && removeItems.isEmpty && clear != true;
}
