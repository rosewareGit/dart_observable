import 'dart:collection';

import 'package:meta/meta.dart';

import '../../../../dart_observable.dart';
import '../_base.dart';
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

class RxMapImpl<K, V> extends RxCollectionBase<Map<K, V>, ObservableMapChange<K, V>>
    with RxMapActionsImpl<K, V>, MapUpdateActionHandler<K, V>
    implements RxMap<K, V> {
  late ObservableMapChange<K, V> _change;

  RxMapImpl({
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(
          (factory ?? defaultMapFactory<K, V>()).call(initial),
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
      added: _value,
    );
  }

  @override
  Map<K, V> get data => _value;

  @override
  int get length => _value.length;

  @override
  UnmodifiableMapView<K, V> get value => UnmodifiableMapView<K, V>(_value);

  Map<K, V> get _value => super.value;

  @override
  V? operator [](final K key) {
    return _value[key];
  }

  @override
  @protected
  ObservableMapChange<K, V>? applyAction(final ObservableMapUpdateAction<K, V> action) {
    final ObservableMapChange<K, V> change = applyActionAndComputeChange(
      data: _value,
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
    return _value.containsKey(key);
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
  Observable<V?> rxItem(final K key) {
    return OperatorObservableMapRxItem<K, V>(
      source: this,
      key: key,
    );
  }

  @override
  void setDataWithChange(final Map<K, V> data, final ObservableMapChange<K, V> change) {
    _change = change;
    super.value = data;
  }

  @override
  ObservableMap<K, V> sorted(final Comparator<V> comparator) {
    return changeFactory((final Map<K, V>? items) {
      return SortedMap<K, V>(comparator, initial: items);
    });
  }

  @override
  List<V> toList() {
    return _value.values.toList();
  }
}
