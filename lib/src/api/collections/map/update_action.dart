import '../update_action.dart';
import 'change.dart';

class ObservableMapUpdateAction<K, V> extends ObservableCollectionUpdateAction {
  ObservableMapUpdateAction({
    required this.removeItems,
    required this.addItems,
  });

  final Map<K, V> addItems;
  final Iterable<K> removeItems;

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableMapChange<K, V> apply(final Map<K, V> updatedMap) {
    return ObservableMapChange.fromAction(
      state: updatedMap,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}
