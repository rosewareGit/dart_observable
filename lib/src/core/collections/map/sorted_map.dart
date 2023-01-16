import 'dart:collection';

class SortedMap<K, V> implements Map<K, V> {
  final Comparator<V> _comparator;
  final K Function(V value) _keyProvider;
  final Map<K, V> _map;
  final SplayTreeSet<V> _sorted;

  SortedMap(
    this._comparator,
    this._keyProvider, {
    final Map<K, V>? initial,
  })  : _map = Map<K, V>.of(initial ?? <K, V>{}),
        _sorted = SplayTreeSet<V>.of(
          (initial ?? <K, V>{}).values,
          _comparator,
        );

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Iterable<V> get values => toList();

  @override
  V? operator [](final Object? key) {
    return _map[key];
  }

  @override
  void operator []=(final K key, final V value) {
    _insert(key, value);
  }

  void add(final K key, final V value) {
    _insert(key, value);
  }

  @override
  void addAll(final Map<K, V> other) {
    _insertAll(other);
  }

  @override
  void addEntries(final Iterable<MapEntry<K, V>> newEntries) {
    // TODO: implement addEntries
  }

  bool any(final bool Function(V element) test) {
    return _map.values.any(test);
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _map.cast<RK, RV>();
  }

  @override
  void clear() {
    _map.clear();
    _sorted.clear();
  }

  @override
  bool containsKey(final Object? key) => _map.containsKey(key);

  @override
  bool containsValue(final Object? value) => _map.containsValue(value);

  @override
  void forEach(final void Function(K key, V value) action) {
    for (final MapEntry<K, V> entry in _map.entries) {
      action(entry.key, entry.value);
    }
  }

  @override
  Map<K2, V2> map<K2, V2>(final MapEntry<K2, V2> Function(K key, V value) convert) {
    return _map.map(convert);
  }

  @override
  V putIfAbsent(final K key, final V Function() ifAbsent) {
    // TODO: implement putIfAbsent
    throw UnimplementedError();
  }

  @override
  V? remove(final Object? key) {
    final V? value = _map.remove(key);
    if (value != null) {
      _sorted.remove(value);
    }
    return value;
  }

  @override
  void removeWhere(final bool Function(K key, V value) test) {
    final Map<K, V> toRemove = <K, V>{};
    for (final MapEntry<K, V> entry in _map.entries) {
      if (test(entry.key, entry.value)) {
        toRemove[entry.key] = entry.value;
      }
    }

    for (final MapEntry<K, V> entry in toRemove.entries) {
      _map.remove(entry.key);
      _sorted.remove(entry.value);
    }
  }

  List<V> toList({final bool growable = true}) {
    final List<V> list = <V>[];
    for (final V value in _sorted) {
      final V? updatedItem = _map[_keyProvider(value)];
      if (updatedItem != null) {
        list.add(updatedItem);
      } else {
        throw StateError('Item not found in map');
      }
    }

    if (growable) {
      return list;
    }

    return List<V>.of(list, growable: false);
  }

  @override
  V update(final K key, final V Function(V value) update, {final V Function()? ifAbsent}) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  void updateAll(final V Function(K key, V value) update) {
    // TODO: implement updateAll
  }

  void _insert(final K key, final V value) {
    final V? current = _map[key];
    _map[key] = value;
    if (current == null) {
      _sorted.add(value);
    } else {
      final int compare = _comparator(current, value);
      if (compare == 0) {
        // Does not need to update the sorted set
        return;
      }

      _sorted.remove(current);
      _sorted.add(value);
    }
  }

  void _insertAll(final Map<K, V> other) {
    for (final MapEntry<K, V> entry in other.entries) {
      _insert(entry.key, entry.value);
    }
  }
}
