import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import 'operators/result_rx_item.dart';

part '../operators/transform_as_map_result.dart';

Map<K, V> Function(Map<K, V>? items) _defaultMapFactory<K, V>() {
  return (final Map<K, V>? items) {
    return Map<K, V>.of(items ?? <K, V>{});
  };
}

class RxMapResultImpl<K, V, F> extends RxImpl<ObservableMapResultState<K, V, F>>
    with ObservableCollectionBase<K, ObservableMapResultChange<K, V, F>, ObservableMapResultState<K, V, F>>
    implements RxMapResult<K, V, F> {
  final Map<K, V> Function(Map<K, V>? items) _factory;

  RxMapResultImpl({
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory<K, V>(),
        super(
          _MutableStateUndefined<K, V, F>(<K, V>{}),
        );

  RxMapResultImpl.failure(
    final F error, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory<K, V>(),
        super(
          _MutableStateFailure<K, V, F>(error, <K, V>{}),
        );

  RxMapResultImpl.fromState(
    final ObservableMapResultState<K, V, F> state, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory(),
        super(state);

  RxMapResultImpl.success(
    final Map<K, V> data, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory(),
        super(
          _MutableStateData<K, V, F>(
              (factory ?? _defaultMapFactory()).call(data), ObservableMapChange<K, V>(added: data)),
        );

  RxMapResultImpl.undefined({
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory(),
        super(
          _MutableStateUndefined<K, V, F>(<K, V>{}),
        );

  RxMapResultImpl.state(
    final ObservableMapResultState<K, V, F> state, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  })  : _factory = factory ?? _defaultMapFactory(),
        super(state);

  @override
  set failure(final F error) {
    applyAction(
      ObservableMapResultUpdateActionFailure<K, V, F>(failure: error),
    );
  }

  @override
  set success(final Map<K, V> data) {
    final ObservableMapChange<K, V> change = _calculateChange(newValue: data);
    super.value = _MutableStateData<K, V, F>(_factory(data), change);
  }

  @override
  set value(final ObservableMapResultState<K, V, F> result) {
    result.when(
      onUndefined: () {
        applyAction(ObservableMapResultUpdateActionUndefined<K, V, F>());
      },
      onFailure: (final F failure) {
        applyAction(ObservableMapResultUpdateActionFailure<K, V, F>(failure: failure));
      },
      onSuccess: (final Map<K, V> data, final ObservableMapChange<K, V> change) {
        success = data;
      },
    );
  }

  @override
  V? operator [](final K key) {
    return value.when<V?>(
      onUndefined: () => null,
      onFailure: (final _) => null,
      onSuccess: (final Map<K, V> data, final _) => data[key],
    );
  }

  @override
  void operator []=(final K key, final V value) {
    // use action
    applyAction(
      ObservableMapResultUpdateActionData<K, V, F>(
        addItems: <K, V>{key: value},
        removeItems: <K>{},
      ),
    );
  }

  @override
  void add(final K key, final V value) {
    applyAction(
      ObservableMapResultUpdateActionData<K, V, F>(
        addItems: <K, V>{key: value},
        removeItems: <K>{},
      ),
    );
  }

  @override
  void addAll(final Map<K, V> other) {
    applyAction(
      ObservableMapResultUpdateActionData<K, V, F>(
        addItems: other,
        removeItems: <K>{},
      ),
    );
  }

  @override
  void applyAction(final ObservableMapResultUpdateAction<K, V, F> action) {
    switch (action) {
      case final ObservableMapResultUpdateActionUndefined<K, V, F> _:
        value.when(
          onUndefined: () {
            // Nothing to do, same state
          },
          onFailure: (final _) {
            super.value = _MutableStateUndefined<K, V, F>(<K, V>{});
          },
          onSuccess: (final UnmodifiableMapView<K, V> data, final ObservableMapChange<K, V> change) {
            super.value = _MutableStateUndefined<K, V, F>(data);
          },
        );
        break;
      case final ObservableMapResultUpdateActionFailure<K, V, F> failure:
        value.when(
          onUndefined: () {
            super.value = _MutableStateFailure<K, V, F>(failure.failure, <K, V>{});
          },
          onFailure: (final _) {
            super.value = _MutableStateFailure<K, V, F>(failure.failure, <K, V>{});
          },
          onSuccess: (final UnmodifiableMapView<K, V> data, final ObservableMapChange<K, V> change) {
            super.value = _MutableStateFailure<K, V, F>(failure.failure, data);
          },
        );
        break;
      case final ObservableMapResultUpdateActionData<K, V, F> data:
        switch (value) {
          case final ObservableMapResultStateData<K, V, F> currentData:
            final _MutableStateData<K, V, F> state = currentData as _MutableStateData<K, V, F>;
            final Map<K, V> updatedMap = state._data;
            final ObservableMapChange<K, V> change = data.apply(updatedMap);
            if (change.isEmpty) {
              return;
            }
            final _MutableStateData<K, V, F> newState = _MutableStateData<K, V, F>(
              updatedMap,
              change,
            );
            super.value = newState;
            break;
          case final ObservableMapResultStateFailure<K, V, F> _:
            final Map<K, V> updatedMap = data.addItems;
            final ObservableMapChange<K, V> change = ObservableMapChange<K, V>(
              added: data.addItems,
            );
            final _MutableStateData<K, V, F> newState = _MutableStateData<K, V, F>(
              _factory(updatedMap),
              change,
            );
            super.value = newState;
            break;
          case final ObservableMapResultStateUndefined<K, V, F> _:
            final Map<K, V> updatedMap = data.addItems;
            final ObservableMapChange<K, V> change = ObservableMapChange<K, V>(
              added: data.addItems,
            );
            final _MutableStateData<K, V, F> newState = _MutableStateData<K, V, F>(
              _factory(updatedMap),
              change,
            );
            super.value = newState;
            break;
        }
        break;
    }
  }

  @override
  void clear() {
    value.when(
      onSuccess: (final Map<K, V> data, final ObservableMapChange<K, V> change) {
        applyAction(
          ObservableMapResultUpdateActionData<K, V, F>(
            addItems: <K, V>{},
            removeItems: data.keys.toSet(),
          ),
        );
      },
    );
  }

  @override
  ObservableMapResult<K, V, F> filterObservableMapAsMapResult(
    final bool Function(K key, V value) predicate, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return transformCollectionAsMapResult(
      factory: factory,
      transform: (
        final ObservableMapResultChange<K, V, F> change,
        final Emitter<ObservableMapResultUpdateAction<K, V, F>> stateUpdate,
      ) {
        change.when(
          onUndefined: (final Map<K, V> removedItems) {
            stateUpdate(ObservableMapResultUpdateActionUndefined<K, V, F>());
          },
          onFailure: (final F failure, final Map<K, V> removedItems) {
            stateUpdate(ObservableMapResultUpdateActionFailure<K, V, F>(failure: failure));
          },
          onSuccess: (final UnmodifiableMapView<K, V> data, final ObservableMapChange<K, V> change) {
            final Map<K, V> itemsToRemove = <K, V>{};
            final Map<K, V> itemsToAdd = <K, V>{};

            change.removed.forEach((final K key, final V value) {
              itemsToRemove[key] = value;
            });
            change.added.forEach((final K key, final V value) {
              if (predicate(key, value)) {
                itemsToAdd[key] = value;
              } else {
                itemsToRemove[key] = value;
              }
            });
            change.updated.forEach((final K key, final ObservableItemChange<V> change) {
              if (predicate(key, change.newValue)) {
                itemsToAdd[key] = change.newValue;
              } else {
                itemsToRemove[key] = change.oldValue;
              }
            });

            final ObservableMapResultUpdateActionData<K, V, F> updateAction =
                ObservableMapResultUpdateActionData<K, V, F>(
              addItems: itemsToAdd,
              removeItems: itemsToRemove.keys.toSet(),
            );
            stateUpdate(updateAction);
          },
        );
      },
    );
  }

  @override
  ObservableMapResult<K, V2, F> mapObservableMapAsMapResult<V2>({
    required final V2 Function(V value) valueMapper,
    final Map<K, V2> Function(Map<K, V2>? items)? factory,
  }) {
    return transformCollectionAsMapResult(
      factory: factory,
      transform: (
        final ObservableMapResultChange<K, V, F> change,
        final Emitter<ObservableMapResultUpdateAction<K, V2, F>> stateUpdate,
      ) {
        change.when(
          onUndefined: (final _) {
            stateUpdate(ObservableMapResultUpdateActionUndefined<K, V2, F>());
          },
          onFailure: (final F failure, final _) {
            stateUpdate(ObservableMapResultUpdateActionFailure<K, V2, F>(failure: failure));
          },
          onSuccess: (final Map<K, V> data, final ObservableMapChange<K, V> change) {
            final Set<K> keysToRemove = <K>{};
            final Map<K, V2> itemsToAdd = <K, V2>{};

            change.removed.forEach((final K key, final V value) {
              keysToRemove.add(key);
            });
            change.added.forEach((final K key, final V value) {
              itemsToAdd[key] = valueMapper(value);
            });
            change.updated.forEach((final K key, final ObservableItemChange<V> change) {
              itemsToAdd[key] = valueMapper(change.newValue);
            });

            final ObservableMapResultUpdateActionData<K, V2, F> updateAction =
                ObservableMapResultUpdateActionData<K, V2, F>(
              addItems: itemsToAdd,
              removeItems: keysToRemove,
            );
            stateUpdate(updateAction);
          },
        );
      },
    );
  }

  @override
  void remove(final K key) {
    applyAction(
      ObservableMapResultUpdateActionData<K, V, F>(
        addItems: <K, V>{},
        removeItems: <K>{key},
      ),
    );
  }

  @override
  void removeWhere(final bool Function(K key, V value) predicate) {
    final Set<K> removeKeys = <K>{};
    value.when(
      onUndefined: () {},
      onFailure: (final _) {},
      onSuccess: (final Map<K, V> data, final ObservableMapChange<K, V> change) {
        for (final MapEntry<K, V> entry in data.entries) {
          if (predicate(entry.key, entry.value)) {
            removeKeys.add(entry.key);
          }
        }
        if (removeKeys.isEmpty) {
          return;
        }
        applyAction(
          ObservableMapResultUpdateActionData<K, V, F>(
            addItems: <K, V>{},
            removeItems: removeKeys,
          ),
        );
      },
    );
  }

  @override
  Observable<V?> rxItem(final K key) {
    return OperatorObservableMapResultRxItem<K, V, F>(
      source: this,
      key: key,
    );
  }

  @override
  void setUndefined() {
    applyAction(
      ObservableMapResultUpdateActionUndefined<K, V, F>(),
    );
  }

  ObservableMapChange<K, V> _calculateChange({required final Map<K, V> newValue}) {
    return value.fold(
      onUndefined: () => ObservableMapChange<K, V>(added: newValue),
      onFailure: (final F f) => ObservableMapChange<K, V>(added: newValue),
      onSuccess: (final UnmodifiableMapView<K, V> data, final _) => ObservableMapChange<K, V>.fromDiff(data, newValue),
    );
  }
}

class _MutableStateData<K, V, F> extends ObservableMapResultStateData<K, V, F> {
  final Map<K, V> _data;

  @override
  final ObservableMapChange<K, V> dataChange;

  _MutableStateData(this._data, this.dataChange);

  @override
  UnmodifiableMapView<K, V> get data => UnmodifiableMapView<K, V>(_data);

  @override
  int get hashCode {
    return _data.hashCode ^ change.hashCode;
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is _MutableStateData<K, V, F> && other._data == _data && other.change == change;
  }

  @override
  ObservableMapResultChange<K, V, F> asChange() {
    return ObservableMapResultChangeData<K, V, F>(
      change: ObservableMapChange<K, V>(added: _data),
      data: data,
    );
  }

  @override
  ObservableMapResultChange<K, V, F> get lastChange => ObservableMapResultChangeData<K, V, F>(
        change: dataChange,
        data: data,
      );
}

class _MutableStateFailure<K, V, F> extends ObservableMapResultStateFailure<K, V, F> {
  @override
  final F failure;

  @override
  final Map<K, V> removedItems;

  _MutableStateFailure(this.failure, this.removedItems);

  @override
  int get hashCode {
    return failure.hashCode ^ removedItems.hashCode;
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is _MutableStateFailure<K, V, F> && other.failure == failure && other.removedItems == removedItems;
  }

  @override
  ObservableMapResultChange<K, V, F> asChange() {
    return ObservableMapResultChangeFailure<K, V, F>(
      failure: failure,
      removedItems: removedItems,
    );
  }

  @override
  ObservableMapResultChange<K, V, F> get lastChange => ObservableMapResultChangeFailure<K, V, F>(
        failure: failure,
        removedItems: removedItems,
      );
}

class _MutableStateUndefined<K, V, F> extends ObservableMapResultStateUndefined<K, V, F> {
  @override
  final Map<K, V> removedItems;

  _MutableStateUndefined(this.removedItems);

  @override
  int get hashCode {
    return removedItems.hashCode;
  }

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is _MutableStateUndefined<K, V, F> && other.removedItems == removedItems;
  }

  @override
  ObservableMapResultChange<K, V, F> asChange() {
    return ObservableMapResultChangeUndefined<K, V, F>(removedItems: removedItems);
  }

  @override
  ObservableMapResultChange<K, V, F> get lastChange => ObservableMapResultChangeUndefined<K, V, F>(
        removedItems: removedItems,
      );
}
