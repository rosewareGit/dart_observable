import '../update_action.dart';
import 'change.dart';

class ObservableSetUpdateAction<E> extends ObservableCollectionUpdateAction {
  final Set<E> addItems;
  final Set<E> removeItems;

  ObservableSetUpdateAction({
    required this.removeItems,
    required this.addItems,
  });

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableSetChange<E> apply(final Set<E> updatedSet) {
    return ObservableSetChange.fromAction(
      sourceToUpdate: updatedSet,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}
