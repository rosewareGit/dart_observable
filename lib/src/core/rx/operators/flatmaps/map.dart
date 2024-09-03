import '../../../../../dart_observable.dart';
import '../../../collections/map/rx_impl.dart';
import '../_base_flat_map.dart';

class OperatorFlatMapAsMap<K, V, T, C> extends RxMapImpl<K, V>
    with BaseFlatMapOperator<ObservableMap<K, V>, T, C, ObservableMapState<K, V>> {
  @override
  final Observable<T> source;
  @override
  final ObservableCollectionFlatMapUpdate<ObservableMap<K, V>> Function(C change) sourceProvider;
  final C Function(T value, bool initial) toChangeFn;

  OperatorFlatMapAsMap({
    required this.source,
    required this.sourceProvider,
    required this.toChangeFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  C fromValue(final T value, final bool initial) => toChangeFn(value, initial);

  @override
  void handleChange(final ObservableMap<K, V> source) {
    final ObservableMapState<K, V> value = source.value;
    final ObservableMapChange<K, V> change = value.lastChange;
    applyAction(
      ObservableMapUpdateAction<K, V>(
        addItems: <K, V>{
          ...change.added,
          ...change.updated.map(
            (final K key, final ObservableItemChange<V> value) => MapEntry<K, V>(key, value.newValue),
          ),
        },
        removeItems: change.removed.keys,
      ),
    );
  }

  @override
  void handleRegisteredObservables(final Set<ObservableMap<K, V>> registerObservables) {
    final Map<K, V> addItems = <K, V>{};

    for (final ObservableMap<K, V> observable in registerObservables) {
      final ObservableMapState<K, V> state = observable.value;
      addItems.addAll(state.mapView);
    }

    applyAction(
      ObservableMapUpdateAction<K, V>(
        addItems: addItems,
        removeItems: <K>{},
      ),
    );
  }

  @override
  void handleRemovedObservables(final Set<ObservableMap<K, V>> unregisterObservables) {
    final Set<K> removeKeys = <K>{};

    for (final ObservableMap<K, V> observable in unregisterObservables) {
      final ObservableMapState<K, V> state = observable.value;
      removeKeys.addAll(state.mapView.keys);
    }

    applyAction(
      ObservableMapUpdateAction<K, V>(
        addItems: <K, V>{},
        removeItems: removeKeys,
      ),
    );
  }
}
