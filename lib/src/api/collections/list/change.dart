import 'dart:collection';

import '../item_change.dart';

class ObservableListChange<E> {
  final Map<int, E> added;
  final Map<int, E> removed;
  final Map<int, ObservableItemChange<E>> updated;

  ObservableListChange({
    final Map<int, E>? added,
    final Map<int, E>? removed,
    final Map<int, ObservableItemChange<E>>? updated,
  })  : added = added ?? <int, E>{},
        removed = removed ?? <int, E>{},
        updated = updated ?? <int, ObservableItemChange<E>>{};

  factory ObservableListChange.fromAdded(
    final List<E> state,
    final Iterable<MapEntry<int?, Iterable<E>>> addItems,
  ) {
    return _handleAdded<E>(state, addItems);
  }

  factory ObservableListChange.fromRemoved(
    final List<E> state,
    final Set<int> removeItems,
  ) {
    return _handleRemoved<E>(state, removeItems);
  }

  factory ObservableListChange.fromUpdated(
    final List<E> state,
    final Map<int, E> updateItems,
  ) {
    return _handleUpdated<E>(state, updateItems);
  }

  bool get isEmpty => added.isEmpty && removed.isEmpty && updated.isEmpty;

  static ObservableListChange<E> _handleAdded<E>(
    final List<E> state,
    final Iterable<MapEntry<int?, Iterable<E>>> addItems,
  ) {
    final Map<int, E> added = <int, E>{};
    final List<E> itemsToAddAtEnd = <E>[];

    // Add items from the end first
    final SplayTreeSet<MapEntry<int, Iterable<E>>> sortedItems = SplayTreeSet<MapEntry<int, Iterable<E>>>(
      (final MapEntry<int, Iterable<E>> left, final MapEntry<int, Iterable<E>> right) {
        return right.key.compareTo(left.key);
      },
    );

    for (final MapEntry<int?, Iterable<E>> entry in addItems) {
      final int? position = entry.key;
      final Iterable<E> items = entry.value;
      if (position == null) {
        itemsToAddAtEnd.addAll(items);
      } else {
        // insert at the position
        if (position < state.length) {
          sortedItems.add(MapEntry<int, Iterable<E>>(position, items));
        } else {
          itemsToAddAtEnd.addAll(items);
        }
      }
    }

    for (final MapEntry<int, Iterable<E>> entry in sortedItems) {
      final int position = entry.key;
      final Iterable<E> items = entry.value;
      int j = 0;
      for (final E item in items) {
        final int pos = position + j++;
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

  static ObservableListChange<E> _handleRemoved<E>(
    final List<E> state,
    final Set<int> removeItems,
  ) {
    final Map<int, E> removed = <int, E>{};
    final SplayTreeSet<int> splayReversed = SplayTreeSet<int>.of(
      removeItems,
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

  static ObservableListChange<E> _handleUpdated<E>(final List<E> state, final Map<int, E> updateItems) {
    final Map<int, ObservableItemChange<E>> updated = <int, ObservableItemChange<E>>{};
    final Map<int, E> added = <int, E>{};

    for (final MapEntry<int, E> entry in updateItems.entries) {
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
