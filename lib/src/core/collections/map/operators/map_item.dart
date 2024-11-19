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
  void handleChange(
    final ObservableMapChange<K, V> change,
  ) {
    mapChange<K, V, V2>(change, applyAction, valueMapper);
  }

  static mapChange<K, V, V2>(
    final ObservableMapChange<K, V> change,
    final Emitter<ObservableMapUpdateAction<K, V2>> updater,
    final V2 Function(K key, V value) valueMapper,
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

    if (removeItems.isNotEmpty || addItems.isNotEmpty) {
      updater(
        ObservableMapUpdateAction<K, V2>(
          removeKeys: removeItems,
          addItems: addItems,
        ),
      );
    }
  }
}
