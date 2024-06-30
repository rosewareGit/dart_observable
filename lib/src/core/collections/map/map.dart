import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import '../operators/_base_transform.dart';
import 'operators/factory.dart';
import 'operators/filter.dart';
import 'operators/map.dart';
import 'operators/rx_item.dart';

part '../operators/transform_as_map.dart';

Map<K, V> Function(Map<K, V>? items) _defaultMapFactory<K, V>() {
  return (final Map<K, V>? items) {
    return Map<K, V>.of(items ?? <K, V>{});
  };
}

class RxMapImpl<K, V> extends RxImpl<ObservableMapState<K, V>>
    with ObservableCollectionBase<K, ObservableMapChange<K, V>, ObservableMapState<K, V>>
    implements RxMap<K, V> {
  final Map<K, V> Function(Map<K, V>? items) _factory;

  RxMapImpl({
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory<K, V>(),
        super(_MutableState<K, V>.initial((factory ?? _defaultMapFactory<K, V>()).call(initial)));

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
  int get length => _value._map.length;

  @override
  set value(final ObservableMapState<K, V> value) {
    final ObservableMapChange<K, V> change = ObservableMapChange<K, V>.fromDiff(this.value.mapView, value.mapView);
    if (change.isEmpty) {
      return;
    }
    super.value = _MutableState<K, V>._(
      _value._map,
      change,
    );
  }

  _MutableState<K, V> get _value => value as _MutableState<K, V>;

  @override
  V? operator [](final K key) {
    return _value._map[key];
  }

  @override
  void operator []=(final K key, final V value) {
    applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{},
        addItems: <K, V>{key: value},
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? add(final K key, final V value) {
    return addAll(<K, V>{key: value});
  }

  @override
  ObservableMapChange<K, V>? addAll(final Map<K, V> other) {
    return applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{},
        addItems: other,
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? applyAction(final ObservableMapUpdateAction<K, V> action) {
    if (disposed) {
      throw ObservableDisposedError();
    }

    final Map<K, V> updatedMap = _value._map;
    final ObservableMapChange<K, V> change = action.apply(updatedMap);
    if (change.isEmpty) {
      return null;
    }

    final _MutableState<K, V> newState = _MutableState<K, V>._(
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
      source: this,
    );
  }

  @override
  ObservableMapChange<K, V>? clear() {
    if (_value._map.isEmpty) {
      return null;
    }

    return applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: _value._map.keys.toSet(),
        addItems: <K, V>{},
      ),
    );
  }

  @override
  bool containsKey(final K key) {
    return _value._map.containsKey(key);
  }

  @override
  ObservableMap<K, V> filterMap(
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
  ObservableMap<K, V2> mapMap<V2>({
    required final V2 Function(K key, V value) valueMapper,
    final FactoryMap<K, V2>? factory,
  }) {
    return OperatorMapMap<K, V, V2>(
      valueMapper: valueMapper,
      source: this,
      factory: factory,
    );
  }

  @override
  ObservableMapChange<K, V>? remove(final K key) {
    return applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{key},
        addItems: <K, V>{},
      ),
    );
  }

  @override
  ObservableMapChange<K, V>? removeWhere(final bool Function(K key, V value) predicate) {
    final Set<K> removed = <K>{};
    for (final MapEntry<K, V> entry in _value._map.entries) {
      if (predicate(entry.key, entry.value)) {
        removed.add(entry.key);
      }
    }
    if (removed.isEmpty) {
      return null;
    }
    return applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: removed,
        addItems: <K, V>{},
      ),
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
  ObservableMapChange<K, V>? setData(final Map<K, V> value) {
    final ObservableMapChange<K, V> change = ObservableMapChange<K, V>.fromDiff(this._value._map, value);
    if (change.isEmpty) {
      return null;
    }

    this.value = _MutableState<K, V>._(
      _factory(value),
      change,
    );
    return change;
  }

  @override
  List<V> toList() {
    return _value._map.values.toList();
  }
}

class _MutableState<K, V> extends ObservableMapState<K, V> {
  final Map<K, V> _map;
  final ObservableMapChange<K, V> _change;

  _MutableState.initial(final Map<K, V> initial)
      : _map = initial,
        _change = ObservableMapChange<K, V>(
          added: initial,
        );

  _MutableState._(final Map<K, V> map, final ObservableMapChange<K, V> change)
      : _map = map,
        _change = change;

  @override
  ObservableMapChange<K, V> get lastChange => _change;

  @override
  UnmodifiableMapView<K, V> get mapView => UnmodifiableMapView<K, V>(_map);

  @override
  ObservableMapChange<K, V> asChange() => ObservableMapChange<K, V>(added: _map);
}
