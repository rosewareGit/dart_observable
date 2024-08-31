import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../map/rx_impl.dart';
import '../_base_flat_map.dart';

class OperatorCollectionsFlatMapAsMap<Self extends ChangeTrackingObservable<Self, CS, C>, E, K, V, C, CS>
    extends RxMapImpl<K, V>
    with
        BaseCollectionFlatMapOperator<Self, ObservableMap<K, V>, CS, ObservableMapState<K, V>, C,
            ObservableMapChange<K, V>> {
  @override
  final Self source;
  @override
  final ObservableCollectionFlatMapUpdate<ObservableMap<K, V>> Function(C change) sourceProvider;

  OperatorCollectionsFlatMapAsMap({
    required this.source,
    required this.sourceProvider,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

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
