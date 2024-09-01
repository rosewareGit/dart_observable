import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../../rx/base_tracking.dart';
import '../_base.dart';
import '../operators/_base_transform.dart';
import 'map_state.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/map_item.dart';
import 'operators/rx_item.dart';
import 'rx_actions.dart';

part '../operators/transforms/map.dart';

Map<K, V> Function(Map<K, V>? items) defaultMapFactory<K, V>() {
  return (final Map<K, V>? items) {
    return Map<K, V>.of(items ?? <K, V>{});
  };
}

class RxMapImpl<K, V> extends RxBaseTracking<ObservableMap<K, V>, ObservableMapState<K, V>, ObservableMapChange<K, V>>
    with
        ObservableCollectionBase<ObservableMap<K, V>, ObservableMapChange<K, V>, ObservableMapState<K, V>>,
        RxMapActionsImpl<K, V>
    implements RxMap<K, V> {
  RxMapImpl({
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(RxMapState<K, V>.initial((factory ?? defaultMapFactory<K, V>()).call(initial)));

  factory RxMapImpl.sorted({
    required final Comparator<V> comparator,
    final Map<K, V>? initial,
  }) {
    return RxMapImpl<K, V>(
      initial: initial,
      factory: (final Map<K, V>? items) {
        return SortedMap<K, V>(comparator, initial: items);
      },
    );
  }

  @override
  Map<K, V> get data => _value.mapView;

  @override
  int get length => _value.data.length;

  @override
  ObservableMap<K, V> get self => this;

  RxMapState<K, V> get _value => value as RxMapState<K, V>;

  @override
  V? operator [](final K key) {
    return _value.data[key];
  }

  @override
  ObservableMapChange<K, V>? applyAction(final ObservableMapUpdateAction<K, V> action) {
    final Map<K, V> updatedMap = _value.data;
    final ObservableMapChange<K, V> change = action.apply(updatedMap);
    if (change.isEmpty) {
      return null;
    }

    final RxMapState<K, V> newState = RxMapState<K, V>(
      updatedMap,
      change,
    );

    super.value = newState;
    return change;
  }

  @override
  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action) {
    return applyAction(action);
  }

  @override
  ObservableMap<K, V> changeFactory(final FactoryMap<K, V> factory) {
    return OperatorMapFactory<K, V>(
      factory: factory,
      source: self,
    );
  }

  @override
  bool containsKey(final K key) {
    return _value.data.containsKey(key);
  }

  @override
  ObservableMap<K, V> filterItem(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorMapFilter<K, V>(
      predicate: predicate,
      source: self,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V2> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  }) {
    return OperatorMapMap<K, V, V2>(
      valueMapper: valueMapper,
      source: self,
      factory: factory,
    );
  }

  @override
  Observable<V?> rxItem(final K key) {
    return OperatorObservableMapRxItem<K, V>(
      source: self,
      key: key,
    );
  }

  @override
  List<V> toList() {
    return _value.data.values.toList();
  }
}
