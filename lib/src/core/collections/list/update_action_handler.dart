import '../../../../dart_observable.dart';
import 'change_elements.dart';
import 'list_element.dart';

abstract interface class ObservableListUpdateActionHandler<E> {
  List<ObservableListElement<E>> get data;

  void onSyncComplete(final ObservableListChangeElements<E> change);
}

mixin ObservableListUpdateActionHandlerImpl<E> implements ObservableListUpdateActionHandler<E> {
  (List<ObservableListElement<E>> data, ObservableListChangeElements<E> change) handleListUpdateAction(
    final List<ObservableListElement<E>> data,
    final ObservableListUpdateAction<E> action,
  ) {
    if (action.isEmpty) {
      return (data, ObservableListChangeElements<E>());
    }

    final Iterable<E> add = action.addItems;
    final Set<int> remove = action.removeItems;
    final Map<int, E> update = action.updateItems;
    final Map<int, Iterable<E>> insert = action.insertAt;

    final ObservableListChangeElements<E> change = ObservableListChangeElements<E>(
      added: <int, ObservableListElement<E>>{},
      removed: <int, ObservableListElementChange<E>>{},
      updated: <int, ObservableListElementChange<E>>{},
    );

    // Update -> remove -> insert -> add
    _handleUpdated(
      data: data,
      change: change,
      updatedItems: update,
    );

    _handleRemoved(
      data: data,
      change: change,
      removedIndexes: remove,
    );

    _handleInsert(
      data: data,
      change: change,
      insertItems: insert,
    );

    _handleAdded(
      data: data,
      change: change,
      add: add,
    );

    return (data, change);
  }

  void _handleAdded({
    required final List<ObservableListElement<E>> data,
    required final ObservableListChangeElements<E> change,
    required final Iterable<E> add,
  }) {
    ObservableListElement<E>? prevElement = data.isEmpty ? null : data.last;
    for (final E item in add) {
      final ObservableListElement<E> element = ObservableListElement<E>(
        value: item,
        previousElement: prevElement,
        nextElement: null,
      );
      prevElement?.nextElement = element;
      prevElement = element;
      data.add(element);
      change.addedElements[data.length - 1] = element;
    }
  }

  void _handleInsert({
    required final List<ObservableListElement<E>> data,
    required final ObservableListChangeElements<E> change,
    required final Map<int, Iterable<E>> insertItems,
  }) {
    for (final MapEntry<int, Iterable<E>> entry in insertItems.entries) {
      final int position = entry.key;
      final List<E> items = entry.value.toList();
      final List<ObservableListElement<E>> addElements = <ObservableListElement<E>>[];
      ObservableListElement<E>? prevElement = data.isEmpty || position == 0 ? null : data.elementAt(position - 1);
      for (int i = 0; i < items.length; i++) {
        final ObservableListElement<E> element = ObservableListElement<E>(
          value: items[i],
          previousElement: prevElement,
          nextElement: null,
        );
        prevElement?.nextElement = element;
        prevElement = element;
        addElements.add(element);
        change.addedElements[position + i] = element;
      }
      data.insertAll(position, addElements);
    }
  }

  void _handleRemoved({
    required final List<ObservableListElement<E>> data,
    required final ObservableListChangeElements<E> change,
    required final Set<int> removedIndexes,
  }) {
    final List<int> sortedDescend = removedIndexes.toList()..sort((final int a, final int b) => b.compareTo(a));

    for (final int index in sortedDescend) {
      if (index >= data.length) {
        continue;
      }
      final ObservableListElement<E> item = data.removeAt(index);
      item.unlink();
      change.removedElements[index] = ObservableListElementChange<E>(
        element: item,
        oldValue: item.value,
        newValue: item.value,
      );
    }
  }

  void _handleUpdated({
    required final List<ObservableListElement<E>> data,
    required final ObservableListChangeElements<E> change,
    required final Map<int, E> updatedItems,
  }) {
    for (final MapEntry<int, E> entry in updatedItems.entries) {
      final int position = entry.key;
      final ObservableListElement<E>? current;
      if (position < data.length) {
        current = data[position];
      } else {
        current = null;
      }

      if (current == null) {
        final ObservableListElement<E> element = ObservableListElement<E>(
          value: entry.value,
          previousElement: data.lastOrNull,
          nextElement: null,
        );
        data.add(element);
        change.addedElements[data.length - 1] = element;
        continue;
      }

      if (current != entry.value) {
        change.updatedElements[position] = ObservableListElementChange<E>(
          element: current,
          oldValue: current.value,
          newValue: entry.value,
        );
        current.value = entry.value;
      }
    }
  }
}
