import '../../../../../dart_observable.dart';
import '../../../rx/base_tracking.dart';
import '../../_base.dart';
import '../map_state.dart';
import '../rx_actions.dart';
import '../rx_impl.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/rx_item.dart';
import 'state.dart';

abstract class RxMapStatefulImpl<Self extends RxMapStateful<O, K, V, S>, O extends ObservableMapStateful<O, K, V, S>, K,
        V, S> extends RxBaseTracking<O, ObservableMapStatefulState<K, V, S>, StateOf<ObservableMapChange<K, V>, S>>
    with
        ObservableCollectionBase<O, StateOf<ObservableMapChange<K, V>, S>, ObservableMapStatefulState<K, V, S>>,
        RxMapActionsImpl<K, V>
    implements RxMapStateful<O, K, V, S> {
  final FactoryMap<K, V> _factory;

  RxMapStatefulImpl(
    super.value, {
    final FactoryMap<K, V>? factory,
  }) : _factory = factory ?? defaultMapFactory<K, V>();

  @override
  Map<K, V> get data => value.fold(
        onData: (final ObservableMapState<K, V> data) => data.mapView,
        onCustom: (final _) => <K, V>{},
      );

  @override
  StateOf<int, S> get length => value.fold(
        onData: (final ObservableMapState<K, V> data) => StateOf<int, S>.data(data.mapView.length),
        onCustom: (final S state) => StateOf<int, S>.custom(state),
      );

  @override
  int? get lengthOrNull => length.data;

  @override
  V? operator [](final K key) {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) {
        return data.mapView[key];
      },
      onCustom: (final _) => null,
    );
  }

  @override
  StateOf<ObservableMapChange<K, V>, S>? applyAction(
    final StateOf<ObservableMapUpdateAction<K, V>, S> action,
  ) {
    final ObservableMapStatefulState<K, V, S> currentValue = value;
    return action.fold<StateOf<ObservableMapChange<K, V>, S>?>(
      onData: (final ObservableMapUpdateAction<K, V> listUpdateAction) {
        return currentValue.fold(
          onData: (final ObservableMapState<K, V> data) {
            final RxMapState<K, V> state = data as RxMapState<K, V>;
            final Map<K, V> updatedMap = state.data;
            final ObservableMapChange<K, V> change = listUpdateAction.apply(updatedMap);

            if (change.isEmpty) {
              return null;
            }

            final RxMapStatefulState<K, V, S> newState = RxMapStatefulState<K, V, S>.data(
              RxMapState<K, V>(updatedMap, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
          onCustom: (final S state) {
            final Map<K, V> updatedMap = _factory(<K, V>{});
            final ObservableMapChange<K, V> change = listUpdateAction.apply(updatedMap);

            final RxMapStatefulState<K, V, S> newState = RxMapStatefulState<K, V, S>.data(
              RxMapState<K, V>(updatedMap, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
        );
      },
      onCustom: (final S action) {
        final RxMapStatefulState<K, V, S> newState = RxMapStatefulState<K, V, S>.custom(action);
        super.value = newState;
        return newState.lastChange;
      },
    );
  }

  @override
  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action) {
    return applyAction(
      StateOf<ObservableMapUpdateAction<K, V>, S>.data(action),
    )?.data;
  }

  @override
  O asObservable() {
    return self;
  }

  Self builder({final Map<K, V>? items, final FactoryMap<K, V>? factory});

  @override
  O changeFactory(final FactoryMap<K, V> factory) {
    final Self instance = builder(items: <K, V>{}, factory: factory);
    OperatorStatefulMapChangeFactory<Self, O, K, V, S>(
      source: self,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  bool containsKey(final K key) {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) => data.mapView.containsKey(key),
      onCustom: (final _) => false,
    );
  }

  @override
  O filterItem(final bool Function(K key, V value) predicate, {final FactoryMap<K, V>? factory}) {
    final Self instance = builder(items: <K, V>{}, factory: factory);
    OperatorStatefulMapFilterItem<Self, O, K, V, S>(
      source: self,
      predicate: predicate,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  Observable<StateOf<V?, S>> rxItem(final K key) {
    return OperatorObservableMapStatefulRxItem<O, K, V, S>(
      source: self,
      key: key,
    );
  }

  @override
  StateOf<ObservableMapChange<K, V>, S>? setState(final S newState) {
    return applyAction(StateOf<ObservableMapUpdateAction<K, V>, S>.custom(newState));
  }

  @override
  List<V>? toList() {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) => data.mapView.values.toList(),
      onCustom: (final _) => null,
    );
  }
}
