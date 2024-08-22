import 'change.dart';

class ObservableMapUpdateAction<K, V> {
  final Map<K, V> addItems;
  final Iterable<K> removeItems;

  ObservableMapUpdateAction({
    required this.removeItems,
    required this.addItems,
  });

  bool get isEmpty => removeItems.isEmpty && addItems.isEmpty;

  ObservableMapChange<K, V> apply(final Map<K, V> updatedMap) {
    return ObservableMapChange.fromAction(
      state: updatedMap,
      addItems: addItems,
      removeItems: removeItems,
    );
  }
}
