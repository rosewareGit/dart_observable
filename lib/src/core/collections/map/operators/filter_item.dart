import '../../../../../dart_observable.dart';
import 'transform.dart';

class OperatorMapFilter<K, V> extends OperatorMapTransform<K, V, K, V> {
  final bool Function(K key, V value) predicate;

  OperatorMapFilter({
    required this.predicate,
    required super.source,
    super.factory,
  });

  @override
  void handleChange(final ObservableMapChange<K, V> change) {
    filterChange(change, applyAction, predicate);
  }

  static void filterChange<K, V>(
    final ObservableMapChange<K, V> change,
    final Emitter<ObservableMapUpdateAction<K, V>> updater,
    final bool Function(K key, V value) predicate,
  ) {
    final Map<K, V> addItems = <K, V>{};
    final Set<K> removeItems = <K>{};
    change.removed.forEach((final K key, final V value) {
      removeItems.add(key);
    });

    change.added.forEach((final K key, final V value) {
      if (predicate(key, value)) {
        addItems[key] = value;
      } else {
        removeItems.add(key);
      }
    });

    change.updated.forEach((final K key, final ObservableItemChange<V> change) {
      if (predicate(key, change.newValue)) {
        addItems[key] = change.newValue;
      } else {
        removeItems.add(key);
      }
    });
    if (addItems.isEmpty && removeItems.isEmpty) {
      return;
    }

    updater(
      ObservableMapUpdateAction<K, V>(
        removeItems: removeItems,
        addItems: addItems,
      ),
    );
  }
}
