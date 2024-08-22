import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../../rx/base_tracking.dart';
import '../_base.dart';
import '../operators/_base_transform.dart';
import 'map_state.dart';
import 'operators/factory.dart';
import 'operators/filter.dart';
import 'operators/map.dart';
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
        ObservableCollectionBase<ObservableMap<K, V>, K, ObservableMapChange<K, V>, ObservableMapState<K, V>>,
        RxMapActionsImpl<K, V>
    implements RxMap<K, V> {
  // TODO check usage
  final Map<K, V> Function(Map<K, V>? items) _factory;

  RxMapImpl({
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? defaultMapFactory<K, V>(),
        super(RxMapState<K, V>.initial((factory ?? defaultMapFactory<K, V>()).call(initial)));

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
  int get length => _value.data.length;

  @override
  set value(final ObservableMapState<K, V> value) {
    final ObservableMapChange<K, V> change = ObservableMapChange<K, V>.fromDiff(this.value.mapView, value.mapView);
    if (change.isEmpty) {
      return;
    }

    super.value = RxMapState<K, V>(
      _value.data,
      change,
    );
  }

  RxMapState<K, V> get _value => value as RxMapState<K, V>;

  @override
  V? operator [](final K key) {
    return _value.data[key];
  }

  @override
  ObservableMapChange<K, V>? applyAction(final ObservableMapUpdateAction<K, V> action) {
    if (disposed) {
      throw ObservableDisposedError();
    }

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
  ObservableMap<K, V> filterMap(
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
  ObservableMap<K, V2> mapMap<V2>({
    required final V2 Function(K key, V value) valueMapper,
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

  @override
  Map<K, V>? get data => _value.mapView;

  @override
  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action) {
    return applyAction(action);
  }

  @override
  ObservableMap<K, V> get self => this;

// @override
// ObservableMapChange<K, V>? setData(final Map<K, V> value) {
//   final Map<K, V>? data = this.data;
//
//   if (data == null) {
//     return addAll(value);
//   }
//
//   final ObservableMapChange<K, V> change = ObservableMapChange<K, V>.fromDiff(data, value);
//   if (change.isEmpty) {
//     return null;
//   }
//
//   this.value = MutableState<K, V>._(
//     _factory(value),
//     change,
//   );
//   return change;
// }
}
