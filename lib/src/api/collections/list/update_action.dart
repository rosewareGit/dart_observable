import '../update_action.dart';
import 'change.dart';

sealed class ObservableListUpdateAction<E> extends ObservableCollectionUpdateAction {
  ObservableListUpdateAction();

  factory ObservableListUpdateAction.add(final List<MapEntry<int?, Iterable<E>>> insertItemAtPosition) {
    return _ObservableListUpdateActionAdd<E>(insertItemAtPosition: insertItemAtPosition);
  }

  factory ObservableListUpdateAction.remove(final Set<int> removeItems) {
    return _ObservableListUpdateActionRemove<E>(removeItems: removeItems);
  }

  factory ObservableListUpdateAction.update(final Map<int, E> updateItemAtPosition) {
    return _ObservableListUpdateActionUpdate<E>(updateItemAtPosition: updateItemAtPosition);
  }

  bool get isEmpty;

  ObservableListChange<E> apply(final List<E> updatedList);
}

class _ObservableListUpdateActionAdd<E> extends ObservableListUpdateAction<E> {
  // Contains the items to add to the list at the given position.
  // If the position is null, the item is added at the end of the list.
  final Iterable<MapEntry<int?, Iterable<E>>> insertItemAtPosition;

  _ObservableListUpdateActionAdd({
    required this.insertItemAtPosition,
  });

  @override
  bool get isEmpty => insertItemAtPosition.isEmpty;

  @override
  ObservableListChange<E> apply(final List<E> updatedList) {
    return ObservableListChange<E>.fromAdded(
      updatedList,
      insertItemAtPosition,
    );
  }
}

class _ObservableListUpdateActionRemove<E> extends ObservableListUpdateAction<E> {
  // Contains the indexes to be removed from the list.
  final Set<int> removeItems;

  _ObservableListUpdateActionRemove({
    required this.removeItems,
  });

  @override
  bool get isEmpty => removeItems.isEmpty;

  @override
  ObservableListChange<E> apply(final List<E> updatedList) {
    return ObservableListChange<E>.fromRemoved(updatedList, removeItems);
  }
}

class _ObservableListUpdateActionUpdate<E> extends ObservableListUpdateAction<E> {
  // Contains the items to be updated at the given position.
  final Map<int, E> updateItemAtPosition;

  _ObservableListUpdateActionUpdate({
    required this.updateItemAtPosition,
  });

  @override
  bool get isEmpty => updateItemAtPosition.isEmpty;

  @override
  ObservableListChange<E> apply(final List<E> updatedList) {
    return ObservableListChange<E>.fromUpdated(
      updatedList,
      updateItemAtPosition,
    );
  }
}
