import '../../../../dart_observable.dart';

class ObservableListUpdateAction<E> {
  final Iterable<E> addItems;
  final Map<int, Iterable<E>> insertAt;
  final Map<int, E> updateItems;
  final Set<int> removeAt;
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
        removeAt = removeAtPositions ?? <int>{};

  factory ObservableListUpdateAction.fromChange(final ObservableListChange<E> change) {
    return ObservableListUpdateAction<E>(
      insertAt: change.added.map((final int index, final E item) => MapEntry<int, List<E>>(index, <E>[item])),
      updateItems: change.updated.map(
        (final int index, final ObservableItemChange<E> update) => MapEntry<int, E>(index, update.newValue),
      ),
      removeAtPositions: change.removed.keys.toSet(),
    );
  }

  bool get isEmpty => addItems.isEmpty && insertAt.isEmpty && updateItems.isEmpty && removeAt.isEmpty && clear != true;
}
