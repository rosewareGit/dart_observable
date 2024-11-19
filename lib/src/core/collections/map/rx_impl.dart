import 'package:meta/meta.dart';

import '../../../../dart_observable.dart';
import '../_base.dart';
import 'map_state.dart';
import 'map_update_action_handler.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/map_item.dart';
import 'operators/rx_item.dart';
import 'rx_actions.dart';

Map<K, V> Function(Map<K, V>? items) defaultMapFactory<K, V>() {
  return (final Map<K, V>? items) {
    return Map<K, V>.of(items ?? <K, V>{});
  };
}

class RxMapImpl<K, V> extends RxCollectionBase<ObservableMapState<K, V>, ObservableMapChange<K, V>>
    with RxMapActionsImpl<K, V>, MapUpdateActionHandler<K, V>
    implements RxMap<K, V> {
  late ObservableMapChange<K, V> _change;

  RxMapImpl({
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(
          RxMapState<K, V>.initial((factory ?? defaultMapFactory<K, V>()).call(initial)),
        ) {
    _change = currentStateAsChange;
  }

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
  ObservableMapChange<K, V> get change => _change;

  @override
  ObservableMapChange<K, V> get currentStateAsChange {
    return ObservableMapChange<K, V>(
      added: _value.data,
    );
  }

  @override
  Map<K, V> get data => _value.mapView;

  @override
  int get length => _value.data.length;

  RxMapState<K, V> get _value => value as RxMapState<K, V>;

  @override
  V? operator [](final K key) {
    return _value.data[key];
  }

  @override
  @protected
  ObservableMapChange<K, V>? applyAction(final ObservableMapUpdateAction<K, V> action) {
    final ObservableMapChange<K, V> change = applyActionAndComputeChange(
      data: _value.data,
      action: action,
    );

    if (change.isEmpty) {
      return null;
    }

    _change = change;
    notify();
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
      source: this,
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
      source: this,
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
      source: this,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> sorted(final Comparator<V> comparator) {
    return changeFactory((final Map<K, V>? items) {
      return SortedMap<K, V>(comparator, initial: items);
    });
  }

  @override
  Observable<V?> rxItem(final K key) {
    return OperatorObservableMapRxItem<K, V>(
      source: this,
      key: key,
    );
  }

  @override
  void setDataWithChange(final Map<K, V> data, final ObservableMapChange<K, V> change) {
    _change = change;
    super.value = RxMapState<K, V>(data);
  }

  @override
  List<V> toList() {
    return _value.data.values.toList();
  }
}
