import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import '../operators/_base_transform.dart';
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
    required final K Function(V value) keyProvider,
    final Map<K, V>? initial,
  }) {
    return RxMapImpl<K, V>(
      initial: initial,
      factory: (final Map<K, V>? items) {
        return SortedMap<K, V>(comparator, keyProvider, initial: items);
      },
    );
  }

  @override
  set data(final Map<K, V> value) {
    this.value = _MutableState<K, V>._(
      _factory(value),
      ObservableMapChange<K, V>(added: value),
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
    // TODO schedule microtask to group within the same event loop
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
  void add(final K key, final V value) {
    addAll(<K, V>{key: value});
  }

  @override
  void addAll(final Map<K, V> other) {
    applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{},
        addItems: other,
      ),
    );
  }

  @override
  void applyAction(final ObservableMapUpdateAction<K, V> action) {
    if (disposed) {
      throw ObservableDisposedError();
    }

    final Map<K, V> updatedMap = _value._map;
    final ObservableMapChange<K, V> change = action.apply(updatedMap);
    if (change.isEmpty) {
      return;
    }

    final _MutableState<K, V> newState = _MutableState<K, V>._(
      updatedMap,
      change,
    );

    super.value = newState;
  }

  @override
  void clear() {
    if (_value._map.isEmpty) {
      return;
    }
    applyAction(
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
  ObservableMap<K, V> filterObservableMapAsMap(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  }) {
    return _doFilter(predicate, factory);
  }

  @override
  ObservableMap<K, V2> mapObservableMapAsMap<V2>({
    required final V2 Function(K key, V value) valueMapper,
    final FactoryMap<K, V2>? factory,
  }) {
    return _doMap<V2>(valueMapper, factory);
  }

  @override
  void remove(final K key) {
    applyAction(
      ObservableMapUpdateAction<K, V>(
        removeItems: <K>{key},
        addItems: <K, V>{},
      ),
    );
  }

  @override
  void removeWhere(final bool Function(K key, V value) predicate) {
    final Set<K> removed = <K>{};
    for (final MapEntry<K, V> entry in _value._map.entries) {
      if (predicate(entry.key, entry.value)) {
        removed.add(entry.key);
      }
    }
    if (removed.isEmpty) {
      return;
    }
    applyAction(
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
  List<V> toList() {
    return _value._map.values.toList();
  }

  ObservableMap<K, V> _doFilter(
    final bool Function(K key, V value) predicate,
    final FactoryMap<K, V>? factory,
  ) {
    return transformCollectionAsMap<K, V>(
      factory: factory,
      transform: (
        final ObservableMap<K, V> state,
        final ObservableMapChange<K, V> change,
        final Emitter<ObservableMapUpdateAction<K, V>> updater,
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
      },
    );
  }

  ObservableMap<K, V2> _doMap<V2>(
    final Function(K key, V value) valueMapper,
    final FactoryMap<K, V2>? factory,
  ) {
    return transformCollectionAsMap<K, V2>(
      factory: factory,
      transform: (
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
      },
    );
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
