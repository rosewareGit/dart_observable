import 'change.dart';

class ObservableSetUpdateAction<E> {
  final Set<E> addItems;
  final Set<E> removeItems;

  ObservableSetUpdateAction({
    final Set<E>? addItems,
    final Set<E>? removeItems,
  })  : addItems = addItems ?? <E>{},
        removeItems = removeItems ?? <E>{};

  factory ObservableSetUpdateAction.fromChange(final ObservableSetChange<E> change) {
    return ObservableSetUpdateAction<E>(
      removeItems: change.removed,
      addItems: change.added,
    );
  }

  ObservableSetChange<E> apply(final Set<E> updatedSet) {
    return ObservableSetChange.fromAction(
      sourceToUpdate: updatedSet,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}
