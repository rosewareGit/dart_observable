import '../item_change.dart';
import 'change.dart';

class ObservableMapUpdateAction<K, V> {
  final Map<K, V> addItems;
  final Iterable<K> removeKeys;

  ObservableMapUpdateAction({
    final Map<K, V>? addItems,
    final Iterable<K>? removeItems,
  })  : addItems = addItems ?? <K, V>{},
        removeKeys = removeItems ?? <K>[];

  factory ObservableMapUpdateAction.fromChange(final ObservableMapChange<K, V> change) {
    return ObservableMapUpdateAction<K, V>(
      addItems: <K, V>{
        ...change.added,
        ...change.updated.map(
          (final K key, final ObservableItemChange<V> value) => MapEntry<K, V>(key, value.newValue),
        ),
      },
      removeItems: change.removed.keys,
    );
  }

  ObservableMapChange<K, V> apply(final Map<K, V> updatedMap) {
    return ObservableMapChange.fromAction(
      state: updatedMap,
      addItems: addItems,
      removeItems: removeKeys,
    );
  }
}
