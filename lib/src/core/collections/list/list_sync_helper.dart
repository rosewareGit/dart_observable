import 'package:collection/collection.dart';

import '../../../../dart_observable.dart';
import 'change_elements.dart';
import 'list_element.dart';
import 'update_action_handler.dart';

class ObservableListSyncHelper<E> {
  final bool Function(E item)? predicate;
  final ObservableListUpdateActionHandler<E> actionHandler;
  final Comparator<E>? comparator;

  ObservableListSyncHelper({
    required this.actionHandler,
    this.predicate,
    this.comparator,
  });

  void handleListSync({
    required final ObservableListChange<E> sourceChange,
  }) {
    final ObservableListChangeElements<E> elementChange = sourceChange as ObservableListChangeElements<E>;
    final Map<int, ObservableListElement<E>> sourceAdded = elementChange.addedElements;
    final Map<int, ObservableListElementChange<E>> sourceUpdated = elementChange.updatedElements;

    final _SyncChange<E> syncChange = _SyncChange<E>();

    final List<ObservableListElement<E>> data = actionHandler.data;

    final bool Function(E item)? predicate = this.predicate;
    final Comparator<E>? comparator = this.comparator;

    final List<ObservableListElementChange<E>> elementsToRemove = <ObservableListElementChange<E>>[];
    for (final MapEntry<int, ObservableListElementChange<E>> change in elementChange.removedElements.entries) {
      elementsToRemove.add(change.value);
    }

    final List<ObservableListElementChange<E>> itemChanges = <ObservableListElementChange<E>>[];

    for (final MapEntry<int, ObservableListElementChange<E>> entry in sourceUpdated.entries) {
      final ObservableListElementChange<E> change = entry.value;
      if (predicate?.call(change.newValue) == false) {
        elementsToRemove.add(change);
      } else {
        itemChanges.add(entry.value);
      }
    }

    if (itemChanges.isNotEmpty) {
      for (int i = 0; i < itemChanges.length; i++) {
        final ObservableListElementChange<E> change = itemChanges[i];
        _handleUpdate(
          change: change,
          comparator: comparator,
          data: data,
          syncChange: syncChange,
        );
      }
    }

    if (elementsToRemove.isNotEmpty) {
      _handleRemove(
        data: data,
        elementsToRemove: elementsToRemove,
        syncChange: syncChange,
      );
    }

    if (sourceAdded.isNotEmpty) {
      _handleAddItems(
        data: data,
        syncChange: syncChange,
        sourceAdded: sourceAdded,
        predicate: predicate,
        comparator: comparator,
      );
    }

    actionHandler.onSyncComplete(
      ObservableListChangeElements<E>(
        added: syncChange.addedElements,
        updated: syncChange.updatedElements,
        removed: syncChange.removedElements,
      ),
    );
  }

  int _getPositionToInsert({
    required final List<ObservableListElement<E>> currentData,
    required final E item,
    required final Comparator<E> comparator,
  }) {
    int low = 0;
    int high = currentData.length;

    while (low < high) {
      final int mid = (low + high) ~/ 2;
      final int compareResult = comparator(currentData[mid].value, item);

      if (compareResult > 0) {
        // If the item should be inserted before the current mid
        high = mid;
      } else {
        // If the item is equal or greater, move low up
        low = mid + 1;
      }
    }

    // At this point, 'low' is the correct position to insert the item
    return low;
  }

  void _handleAddItems({
    required final Map<int, ObservableListElement<E>> sourceAdded,
    required final List<ObservableListElement<E>> data,
    required final _SyncChange<E> syncChange,
    final bool Function(E item)? predicate,
    final Comparator<E>? comparator,
  }) {
    final Map<int, ObservableListElement<E>> addItems;
    if (predicate == null) {
      addItems = sourceAdded;
    } else {
      addItems = Map<int, ObservableListElement<E>>.fromEntries(
        sourceAdded.entries.where((final MapEntry<int, ObservableListElement<E>> entry) {
          return predicate(entry.value.value);
        }),
      );
    }

    if (addItems.isEmpty) {
      return;
    }

    if (comparator != null) {
      _handleAddItemsWithComparator(
        addItems: addItems.values,
        comparator: comparator,
        data: data,
        syncChange: syncChange,
      );
      return;
    }

    for (final MapEntry<int, ObservableListElement<E>> entry in addItems.entries) {
      final ObservableListElement<E> element = entry.value;

      //find the first element that exists in this list and insert after it
      int index = -1;
      ObservableListElement<E> currentElement = element;
      while (true) {
        final ObservableListElement<E>? prev = currentElement.previousElement;
        if (prev == null) {
          break;
        }

        final int indexInTarget = data.indexOf(prev);
        if (indexInTarget != -1) {
          index = indexInTarget + 1;
          break;
        }
        currentElement = prev;
      }
      if (index == -1) {
        data.add(element);
      } else {
        data.insert(index, element);
      }
      syncChange.addedElements[index == -1 ? data.length - 1 : index] = element;
    }
  }

  void _handleAddItemsWithComparator({
    required final Iterable<ObservableListElement<E>> addItems,
    required final Comparator<E> comparator,
    required final List<ObservableListElement<E>> data,
    required final _SyncChange<E> syncChange,
  }) {
    final Map<int, List<ObservableListElement<E>>> itemsToInsert = <int, List<ObservableListElement<E>>>{};
    final List<ObservableListElement<E>> sortedItems = addItems.sorted(
      (final ObservableListElement<E> left, final ObservableListElement<E> right) {
        return comparator(left.value, right.value);
      },
    );

    final int length = sortedItems.length;
    for (int i = 0; i < length; ++i) {
      final ObservableListElement<E> item = sortedItems[i];
      final int position = _getPositionToInsert(
        currentData: data,
        item: item.value,
        comparator: comparator,
      );

      itemsToInsert.putIfAbsent(position, () => <ObservableListElement<E>>[]).add(item);
    }

    final List<MapEntry<int, List<ObservableListElement<E>>>> entries = itemsToInsert.entries.toList();
    final int entriesLength = entries.length;

    for (int i = 0; i < entriesLength; ++i) {
      final MapEntry<int, List<ObservableListElement<E>>> entry = entries[i];
      final int position = entry.key;
      final List<ObservableListElement<E>> items = entry.value;
      data.insertAll(position, items);

      for (int j = 0; j < items.length; j++) {
        syncChange.addedElements[position + j] = items[j];
      }
    }
  }

  void _handleRemove({
    required final List<ObservableListElement<E>> data,
    required final List<ObservableListElementChange<E>> elementsToRemove,
    required final _SyncChange<E> syncChange,
  }) {
    final List<ObservableListElement<E>> currentData = data;

    for (final ObservableListElementChange<E> change in elementsToRemove) {
      final ObservableListElement<E> element = change.element;
      final int index = currentData.indexOf(element);
      if (index != -1) {
        syncChange.removedElements[index] = change;
        currentData.removeAt(index);
      }
    }
  }

  void _handleUpdate({
    required final ObservableListElementChange<E> change,
    required final List<ObservableListElement<E>> data,
    required final _SyncChange<E> syncChange,
    required final Comparator<E>? comparator,
  }) {
    final ObservableListElement<E> element = change.element;
    final int index = data.indexOf(element);
    if (index == -1) {
      return;
    }

    syncChange.updatedElements[index] = change;

    if (comparator != null) {
      // remove old element and insert it in the correct position
      data.removeAt(index);
      final int position = _getPositionToInsert(
        currentData: data,
        item: change.newValue,
        comparator: comparator,
      );

      data.insert(position, element);
    }
  }
}

class _SyncChange<E> {
  final Map<int, ObservableListElement<E>> addedElements = <int, ObservableListElement<E>>{};
  final Map<int, ObservableListElementChange<E>> removedElements = <int, ObservableListElementChange<E>>{};
  final Map<int, ObservableListElementChange<E>> updatedElements = <int, ObservableListElementChange<E>>{};
}
