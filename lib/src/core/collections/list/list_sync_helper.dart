import 'dart:collection';

import 'package:meta/meta.dart';

import '../../../../dart_observable.dart';

// Keeps the index connection between 2 observable list.
// Receives the source state/change and updates the mapping based no the action result.
class ObservableListSyncHelper<E> {
  final bool Function(E item)? predicate;
  final E2 Function<E2>(E item)? mapper;
  final RxList<E> target;

  ObservableListSyncHelper({
    required this.target,
    this.predicate,
    this.mapper,
  });

  // key: index in source, value: index in target
  @visibleForTesting
  final Map<int, int> $indexMapper = <int, int>{};

  void handleListChange({
    required final ObservableListChange<E> sourceChange,
  }) {
    final Map<int, E> sourceAdded = sourceChange.added;
    final Map<int, E> sourceRemoved = sourceChange.removed;
    final Map<int, ObservableItemChange<E>> sourceUpdated = sourceChange.updated;

    final Map<int, E> updateActionData = <int, E>{};
    final Set<int> indexToRemove = <int>{};

    for (final MapEntry<int, ObservableItemChange<E>> entry in sourceUpdated.entries) {
      final int key = entry.key;
      final int? indexInSource = $indexMapper[key];
      if (indexInSource == null) {
        continue;
      }
      if (predicate?.call(entry.value.newValue) == false) {
        indexToRemove.add(indexInSource);
      } else {
        updateActionData[indexInSource] = entry.value.newValue;
      }
    }

    target.applyAction(
      ObservableListUpdateAction<E>(updateItemAtPosition: updateActionData),
    );

    final Map<int, int> updatedIndexMapper = Map<int, int>.fromEntries($indexMapper.entries);

    for (final int removedIndex in sourceRemoved.keys) {
      final int? valueInTarget = $indexMapper.remove(removedIndex);
      updatedIndexMapper.remove(removedIndex);
      if (valueInTarget != null) {
        indexToRemove.add(valueInTarget);
      }
      for (final MapEntry<int, int> entry in updatedIndexMapper.entries) {
        if (entry.key > removedIndex) {
          $indexMapper.remove(entry.key);
          // Shift the index
          $indexMapper[entry.key - 1] = valueInTarget == null ? entry.value : entry.value - 1;
        }
      }
    }

    target.applyAction(
      ObservableListUpdateAction<E>(removeIndexes: indexToRemove),
    );

    for (final MapEntry<int, E> entry in sourceAdded.entries) {
      final int removedIndexesBefore = sourceRemoved.keys.where((final int element) => element <= entry.key).length;
      final int indexInSource = entry.key - removedIndexesBefore;
      final E value = entry.value;
      if (predicate?.call(value) == false) {
        continue;
      }

      final ObservableListChange<E>? resultChange = target.applyAction(
        ObservableListUpdateAction<E>(
          insertItemAtPosition: <MapEntry<int?, Iterable<E>>>[
            MapEntry<int?, Iterable<E>>(null, <E>[entry.value]),
          ],
        ),
      );

      if (resultChange != null) {
        final MapEntry<int, E>? added = resultChange.added.entries.firstOrNull;
        if (added != null) {
          $indexMapper[indexInSource] = added.key;
        }
      }
    }
  }

  Iterable<int> handleRemovedState(final ObservableList<E> activeObservable) {
    final UnmodifiableListView<E> itemsToRemove = activeObservable.value.listView;
    final List<int> removeIndexes = <int>[];
    for (int i = 0; i < itemsToRemove.length; i++) {
      final int index = $indexMapper.remove(i) ?? -1;
      if (index != -1) {
        removeIndexes.add(index);
      }
    }
    return removeIndexes;
  }

  void handleInitialState({
    required final ObservableList<E> state,
  }) {
    final UnmodifiableListView<E> itemsToAdd = state.value.listView;

    for (int i = 0; i < itemsToAdd.length; i++) {
      final ObservableListChange<E>? addedChange = target.applyAction(
        ObservableListUpdateAction<E>(
          insertItemAtPosition: <MapEntry<int?, Iterable<E>>>[
            MapEntry<int?, Iterable<E>>(null, <E>[itemsToAdd[i]]),
          ],
        ),
      );

      if (addedChange != null) {
        final MapEntry<int, E>? added = addedChange.added.entries.firstOrNull;
        if (added != null) {
          $indexMapper[i] = added.key;
        }
      }
    }
  }
}