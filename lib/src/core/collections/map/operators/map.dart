import '../../../../../dart_observable.dart';
import 'transform.dart';

class OperatorMapMap<K, V, V2> extends OperatorMapTransform<K, V, K, V2> {
  final V2 Function(K key, V value) valueMapper;

  OperatorMapMap({
    required this.valueMapper,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final ObservableMap<K, V2> state,
    final ObservableMapChange<K, V> change,
    final Emitter<ObservableMapUpdateAction<K, V2>> updater,
  ) {
    final Map<K, V2> addItems = <K, V2>{};
    final Set<K> removeItems = <K>{};

    change.removed.forEach((final K key, final V value) {
      removeItems.add(key);
    });
    change.added.forEach((final K key, final V value) {
      addItems[key] = valueMapper(key, value);
    });
    change.updated.forEach((final K key, final ObservableItemChange<V> change) {
      addItems[key] = valueMapper(key, change.newValue);
    });
    if (addItems.isEmpty && removeItems.isEmpty) {
      return;
    }
    updater(
      ObservableMapUpdateAction<K, V2>(
        removeItems: removeItems,
        addItems: addItems,
      ),
    );
  }
}
