import '../../update_action.dart';
import '../change.dart';
import '../update_action.dart';

sealed class ObservableListResultUpdateAction<E, F> extends ObservableCollectionUpdateAction {}

class ObservableListResultUpdateActionData<E, F> extends ObservableListResultUpdateAction<E, F> {
  final Iterable<MapEntry<int?, Iterable<E>>> insertItemAtPosition;
  final Set<int> removeIndexes;
  final Map<int, E> updateItemAtPosition;

  ObservableListResultUpdateActionData({
    final Iterable<MapEntry<int?, Iterable<E>>>? insertItemAtPosition,
    final Set<int>? removeIndexes,
    final Map<int, E>? updateItemAtPosition,
  })  : insertItemAtPosition = insertItemAtPosition ?? <MapEntry<int?, Iterable<E>>>[],
        removeIndexes = removeIndexes ?? <int>{},
        updateItemAtPosition = updateItemAtPosition ?? <int, E>{};

  factory ObservableListResultUpdateActionData.add(final List<MapEntry<int?, Iterable<E>>> insertItemAtPosition) {
    return ObservableListResultUpdateActionData<E, F>(insertItemAtPosition: insertItemAtPosition);
  }

  factory ObservableListResultUpdateActionData.remove(final Set<int> removeIndexes) {
    return ObservableListResultUpdateActionData<E, F>(removeIndexes: removeIndexes);
  }

  factory ObservableListResultUpdateActionData.update(final Map<int, E> updateItemAtPosition) {
    return ObservableListResultUpdateActionData<E, F>(updateItemAtPosition: updateItemAtPosition);
  }

  ObservableListChange<E> apply(final List<E> updatedList) {
    return ObservableListUpdateAction<E>(
      insertItemAtPosition: insertItemAtPosition,
      removeIndexes: removeIndexes,
      updateItemAtPosition: updateItemAtPosition,
    ).apply(updatedList);
  }
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
