import '../../update_action.dart';
import '../change.dart';

sealed class ObservableListResultUpdateAction<E, F> extends ObservableCollectionUpdateAction {
  void when({
    final void Function()? onUndefined,
    final void Function(F failure)? onFailure,
    final void Function(ObservableListResultUpdateActionData<E, F> data)? onData,
  }) {
    switch (this) {
      case ObservableListResultUpdateActionUndefined<E, F> _:
        if (onUndefined != null) {
          onUndefined();
        }
        break;
      case final ObservableListResultUpdateActionFailure<E, F> failure:
        if (onFailure != null) {
          onFailure(failure.failure);
        }
        break;
      case final ObservableListResultUpdateActionData<E, F> data:
        if (onData != null) {
          onData(data);
        }
        break;
    }
  }
}

sealed class ObservableListResultUpdateActionData<E, F> extends ObservableListResultUpdateAction<E, F> {
  ObservableListResultUpdateActionData();

  factory ObservableListResultUpdateActionData.add(final List<MapEntry<int?, Iterable<E>>> insertItemAtPosition) {
    return _ObservableListResultUpdateActionDataAdd<E, F>(insertItemAtPosition: insertItemAtPosition);
  }

  factory ObservableListResultUpdateActionData.remove(final Iterable<int> removeItems) {
    return _ObservableListResultUpdateActionDataRemove<E, F>(removeItems: removeItems);
  }

  factory ObservableListResultUpdateActionData.update(final Map<int, E> updateItemAtPosition) {
    return _ObservableListResultUpdateActionDataUpdate<E, F>(updateItemAtPosition: updateItemAtPosition);
  }

  bool get isEmpty;

  ObservableListChange<E> apply(final List<E> updatedList);
}

class ObservableListResultUpdateActionFailure<E, F> extends ObservableListResultUpdateAction<E, F> {
  final F failure;

  ObservableListResultUpdateActionFailure({
    required this.failure,
  });
}

class ObservableListResultUpdateActionUndefined<E, F> extends ObservableListResultUpdateAction<E, F> {
  ObservableListResultUpdateActionUndefined();
}

class _ObservableListResultUpdateActionDataAdd<E, F> extends ObservableListResultUpdateActionData<E, F> {
  // Contains the items to add to the list at the given position.
  // If the position is null, the item is added at the end of the list.
  final Iterable<MapEntry<int?, Iterable<E>>> insertItemAtPosition;

  _ObservableListResultUpdateActionDataAdd({
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

class _ObservableListResultUpdateActionDataRemove<E, F> extends ObservableListResultUpdateActionData<E, F> {
  // Contains the indexes to be removed from the list.
  final Iterable<int> removeItems;

  _ObservableListResultUpdateActionDataRemove({
    required this.removeItems,
  });

  @override
  bool get isEmpty => removeItems.isEmpty;

  @override
  ObservableListChange<E> apply(final List<E> updatedList) {
    return ObservableListChange<E>.fromRemoved(updatedList, removeItems);
  }
}

class _ObservableListResultUpdateActionDataUpdate<E, F> extends ObservableListResultUpdateActionData<E, F> {
  // Contains the items to be updated at the given position.
  final Map<int, E> updateItemAtPosition;

  _ObservableListResultUpdateActionDataUpdate({
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
