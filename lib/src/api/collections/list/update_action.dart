import 'dart:collection';

import '../../../../dart_observable.dart';

class ObservableListUpdateAction<E> {
  final Iterable<MapEntry<int?, Iterable<E>>> insertItemAtPosition;
  final Set<int> removeIndexes;
  final Map<int, E> updateItemAtPosition;

  ObservableListUpdateAction({
    final Iterable<MapEntry<int?, Iterable<E>>>? insertItemAtPosition,
    final Set<int>? removeIndexes,
    final Map<int, E>? updateItemAtPosition,
  })  : insertItemAtPosition = insertItemAtPosition ?? <MapEntry<int?, Iterable<E>>>[],
        removeIndexes = removeIndexes ?? <int>{},
        updateItemAtPosition = updateItemAtPosition ?? <int, E>{};

  factory ObservableListUpdateAction.add(final Iterable<MapEntry<int?, Iterable<E>>> insertItemAtPosition) {
    return ObservableListUpdateAction<E>(insertItemAtPosition: insertItemAtPosition);
  }

  factory ObservableListUpdateAction.remove(final Set<int> removeIndexes) {
    return ObservableListUpdateAction<E>(removeIndexes: removeIndexes);
  }

  factory ObservableListUpdateAction.update(final Map<int, E> updateItemAtPosition) {
    return ObservableListUpdateAction<E>(updateItemAtPosition: updateItemAtPosition);
  }

  bool get isEmpty {
    return insertItemAtPosition.isEmpty && removeIndexes.isEmpty && updateItemAtPosition.isEmpty;
  }

  ObservableListChange<E> apply(final List<E> updatedList) {
    if (isEmpty) {
      return ObservableListChange<E>();
    }

    final ObservableListChange<E> updated = _handleUpdated(updatedList);
    final ObservableListChange<E> removed = _handleRemoved(updatedList);
    final ObservableListChange<E> added = _handleAdded(updatedList);

    return ObservableListChange<E>(
      added: <int, E>{
        ...added.added,
        ...updated.added,
      },
      removed: removed.removed,
      updated: updated.updated,
    );
  }

  ObservableListChange<E> _handleAdded(final List<E> state) {
    final Map<int, E> added = <int, E>{};
    final List<E> itemsToAddAtEnd = <E>[];

    final Map<int, Iterable<E>> addItemsAtPosition = <int, Iterable<E>>{};

    for (final MapEntry<int?, Iterable<E>> entry in insertItemAtPosition) {
      final int? position = entry.key;
      final Iterable<E> items = entry.value;
      if (position == null) {
        itemsToAddAtEnd.addAll(items);
      } else {
        // insert at the position
        if (position < state.length) {
          addItemsAtPosition[position] = items;
        } else {
          itemsToAddAtEnd.addAll(items);
        }
      }
    }

    for (final MapEntry<int, Iterable<E>> entry in addItemsAtPosition.entries) {
      final int itemsAddedBefore = added.keys.where((final int element) => element <= entry.key).length;
      final int position = entry.key + itemsAddedBefore;
      final Iterable<E> items = entry.value;
      int j = 0;
      for (final E item in items) {
        final int pos = position + j++;
        if (added.keys.any((final int element) => element >= pos)) {
          // shift all existing items
          final Map<int, E> shifted = <int, E>{};
          for (final MapEntry<int, E> addedEntry in added.entries) {
            if (addedEntry.key >= pos) {
              shifted[addedEntry.key + 1] = addedEntry.value;
            } else {
              shifted[addedEntry.key] = addedEntry.value;
            }
          }
          added.clear();
          added.addAll(shifted);
        }
        added[pos] = item;
        state.insert(pos, item);
      }
    }

    // Add at the end of the list
    for (final E item in itemsToAddAtEnd) {
      added[state.length] = item;
      state.add(item);
    }
    return ObservableListChange<E>(
      added: added,
    );
  }

  ObservableListChange<E> _handleRemoved(final List<E> state) {
    final Map<int, E> removed = <int, E>{};
    final SplayTreeSet<int> splayReversed = SplayTreeSet<int>.of(
      removeIndexes,
      (final int a, final int b) => b.compareTo(a),
    );
    for (final int position in splayReversed) {
      final E? current = state.length > position ? state[position] : null;
      if (current != null) {
        removed[position] = current;
        state.removeAt(position);
      }
    }
    return ObservableListChange<E>(
      removed: removed,
    );
  }

  ObservableListChange<E> _handleUpdated(final List<E> state) {
    final Map<int, ObservableItemChange<E>> updated = <int, ObservableItemChange<E>>{};
    final Map<int, E> added = <int, E>{};

    for (final MapEntry<int, E> entry in updateItemAtPosition.entries) {
      final int position = entry.key;
      if (position < state.length) {
        final E current = state[position];
        if (current != entry.value) {
          updated[position] = ObservableItemChange<E>(
            oldValue: current,
            newValue: entry.value,
          );
          state[position] = entry.value;
        }
      } else {
        state.add(entry.value);
        added[position] = entry.value;
      }
    }

    return ObservableListChange<E>(
      updated: updated,
      added: added,
    );
  }
}
