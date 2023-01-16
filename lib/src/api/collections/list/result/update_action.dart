import '../../update_action.dart';
import '../change.dart';

sealed class ObservableListResultUpdateAction<E, F> extends ObservableCollectionUpdateAction {
  void when({
    final void Function()? onUndefined,
    final void Function(F failure)? onFailure,
    final void Function(ObservableListResultUpdateActionData<E,F> data)? onData,
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

class ObservableListResultUpdateActionUndefined<E, F> extends ObservableListResultUpdateAction<E, F> {
  ObservableListResultUpdateActionUndefined();
}

class ObservableListResultUpdateActionFailure<E, F> extends ObservableListResultUpdateAction<E, F> {
  ObservableListResultUpdateActionFailure({
    required this.failure,
  });

  final F failure;
}

class ObservableListResultUpdateActionData<E, F> extends ObservableListResultUpdateAction<E, F> {
  ObservableListResultUpdateActionData({
    final Set<int>? removeItems,
    final Map<int, E>? updateItemAtPosition,
    final List<MapEntry<int?, Iterable<E>>>? addItems,
  })  : removeItems = removeItems ?? <int>{},
        updateItemAtPosition = updateItemAtPosition ?? <int, E>{},
        insertItemAtPosition = addItems ?? <MapEntry<int?, Iterable<E>>>[];

  // Contains the items to add to the list at the given position.
  // If the position is null, the item is added at the end of the list.
  final List<MapEntry<int?, Iterable<E>>> insertItemAtPosition;

  // Contains the items to be updated at the given position.
  final Map<int, E> updateItemAtPosition;

  // Contains the indexes to be removed from the list.
  final Set<int> removeItems;

  bool get isEmpty => removeItems.isEmpty && insertItemAtPosition.isEmpty && updateItemAtPosition.isEmpty;

  ObservableListChange<E> apply(final List<E> updatedList) {
    // return ObservableListChange.fromAction(
    //   state: updatedList,
    //   insertItemAtPosition: insertItemAtPosition,
    //   updateItemAtPosition: updateItemAtPosition,
    //   removeItems: removeItems,
    // );

    // TODO
    return ObservableListChange();
  }
}
