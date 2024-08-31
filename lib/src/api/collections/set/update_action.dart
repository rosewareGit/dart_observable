import 'change.dart';

class ObservableSetUpdateAction<E> {
  final Set<E> addItems;
  final Set<E> removeItems;

  ObservableSetUpdateAction({
    required this.removeItems,
    required this.addItems,
  });

  factory ObservableSetUpdateAction.fromChange(final ObservableSetChange<E> change) {
    return ObservableSetUpdateAction<E>(
      removeItems: change.removed,
      addItems: change.added,
    );
  }

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableSetChange<E> apply(final Set<E> updatedSet) {
    return ObservableSetChange.fromAction(
      sourceToUpdate: updatedSet,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}
