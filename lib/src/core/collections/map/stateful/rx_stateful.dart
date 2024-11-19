import 'package:meta/meta.dart';

import '../../../../../dart_observable.dart';
import '../../_base_stateful.dart';
import '../map_state.dart';
import '../map_update_action_handler.dart';
import '../rx_actions.dart';
import '../rx_impl.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/filter_item_state.dart';
import 'operators/map_item.dart';
import 'operators/map_item_state.dart';
import 'operators/rx_item.dart';
import 'state.dart';

class RxStatefulMapImpl<K, V, S> extends RxCollectionStatefulBase<
    ObservableMapState<K, V>,
    ObservableStatefulMapState<K, V, S>,
    ObservableMapChange<K, V>,
    S> with RxMapActionsImpl<K, V>, MapUpdateActionHandler<K, V> implements RxStatefulMap<K, V, S> {
  final FactoryMap<K, V> _factory;
  late Either<ObservableMapChange<K, V>, S> _change;

  RxStatefulMapImpl(
    final Map<K, V> data, {
    final FactoryMap<K, V>? factory,
  }) : this._(
          () {
            final FactoryMap<K, V> $factory = factory ?? defaultMapFactory<K, V>();
            final Map<K, V> updatedMap = $factory(data);
            return RxStatefulMapState<K, V, S>.fromState(RxMapState<K, V>.initial(updatedMap));
          }(),
          factory: factory,
        );

  factory RxStatefulMapImpl.custom(
    final S state, {
    final FactoryMap<K, V>? factory,
  }) {
    return RxStatefulMapImpl<K, V, S>._(
      RxStatefulMapState<K, V, S>.custom(state),
      factory: factory,
    );
  }

  RxStatefulMapImpl._(
    final ObservableStatefulMapState<K, V, S> state, {
    final FactoryMap<K, V>? factory,
  })  : _factory = factory ?? defaultMapFactory<K, V>(),
        super(state) {
    _change = currentStateAsChange;
  }

  @override
  Map<K, V> get data => value.fold(
        onData: (final ObservableMapState<K, V> data) => data.mapView,
        onCustom: (final _) => <K, V>{},
      );

  @override
  int? get length => value.fold(
        onData: (final ObservableMapState<K, V> data) => data.mapView.length,
        onCustom: (final S state) => null,
      );

  @override
  V? operator [](final K key) {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) {
        return data.mapView[key];
      },
      onCustom: (final _) => null,
    );
  }

  @protected
  Either<ObservableMapChange<K, V>, S>? applyAction(
    final Either<ObservableMapUpdateAction<K, V>, S> action,
  ) {
    final ObservableStatefulMapState<K, V, S> currentValue = value;
    return action.fold<Either<ObservableMapChange<K, V>, S>?>(
      onLeft: (final ObservableMapUpdateAction<K, V> listUpdateAction) {
        return currentValue.fold(
          onData: (final ObservableMapState<K, V> data) {
            final RxMapState<K, V> state = data as RxMapState<K, V>;
            final Map<K, V> updatedMap = state.data;
            final ObservableMapChange<K, V> change = applyActionAndComputeChange(
              data: updatedMap,
              action: listUpdateAction,
            );

            if (change.isEmpty) {
              return null;
            }

            final RxStatefulMapState<K, V, S> newState = RxStatefulMapState<K, V, S>.fromState(
              RxMapState<K, V>(updatedMap),
            );

            _change = Either<ObservableMapChange<K, V>, S>.left(change);
            super.value = newState;
            return _change;
          },
          onCustom: (final S state) {
            final Map<K, V> updatedMap = _factory(<K, V>{});
            final ObservableMapChange<K, V> change = applyActionAndComputeChange(
              data: updatedMap,
              action: listUpdateAction,
            );

            final RxStatefulMapState<K, V, S> newState = RxStatefulMapState<K, V, S>.fromState(
              RxMapState<K, V>(updatedMap),
            );

            _change = Either<ObservableMapChange<K, V>, S>.left(change);
            super.value = newState;
            return _change;
          },
        );
      },
      onRight: (final S action) {
        final RxStatefulMapState<K, V, S> newState = RxStatefulMapState<K, V, S>.custom(action);
        _change = Either<ObservableMapChange<K, V>, S>.right(action);
        super.value = newState;
        return _change;
      },
    );
  }

  @override
  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action) {
    return applyAction(
      Either<ObservableMapUpdateAction<K, V>, S>.left(action),
    )?.leftOrNull;
  }

  @override
  ObservableStatefulMap<K, V, S> changeFactory(final FactoryMap<K, V> factory) {
    return OperatorStatefulMapChangeFactory<K, V, S>(
      source: this,
      factory: factory,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> sorted(final Comparator<V> comparator) {
    return changeFactory(
      (final Map<K, V>? items){
        return SortedMap<K,V>(comparator, initial: items);
      },
    );
  }

  @override
  bool containsKey(final K key) {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) => data.mapView.containsKey(key),
      onCustom: (final _) => false,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> filterItem(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorStatefulMapFilterItem<K, V, S>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> filterItemWithState(
    final bool Function(Either<MapEntry<K, V>, S>) predicate, {
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorStatefulMapFilterItemWithState<K, V, S>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableStatefulMap<K, V2, S> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  }) {
    return OperatorStatefulMapMapItem<K, V, V2, S>(
      source: this,
      mapper: valueMapper,
      factory: factory,
    );
  }

  @override
  ObservableStatefulMap<K, V2, S2> mapItemWithState<V2, S2>({
    required final V2 Function(K key, V value) valueMapper,
    required final S2 Function(S state) stateMapper,
    final FactoryMap<K, V2>? factory,
  }) {
    return OperatorStatefulMapMapItemWithState<K, V, V2, S, S2>(
      source: this,
      mapper: valueMapper,
      stateMapper: stateMapper,
      factory: factory,
    );
  }

  @override
  Observable<Either<V?, S>> rxItem(final K key) {
    return OperatorObservableMapStatefulRxItem<K, V, S>(
      source: this,
      key: key,
    );
  }

  @override
  Either<ObservableMapChange<K, V>, S>? setState(final S newState) {
    return applyAction(Either<ObservableMapUpdateAction<K, V>, S>.right(newState));
  }

  @override
  List<V>? toList() {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) => data.mapView.values.toList(),
      onCustom: (final _) => null,
    );
  }

  @override
  void setDataWithChange(final Map<K, V> data, final ObservableMapChange<K, V> change) {
    _change = Either<ObservableMapChange<K, V>, S>.left(change);
    super.value = RxStatefulMapState<K, V, S>.fromState(
      RxMapState<K, V>(data),
    );
  }

  @override
  Either<ObservableMapChange<K, V>, S> get change => _change;

  @override
  Either<ObservableMapChange<K, V>, S> get currentStateAsChange {
    return value.fold(
      onData: (final ObservableMapState<K, V> data) {
        final ObservableMapChange<K, V> change = ObservableMapChange<K, V>(
          added: (data as RxMapState<K, V>).data,
        );
        return Either<ObservableMapChange<K, V>, S>.left(change);
      },
      onCustom: (final S state) {
        return Either<ObservableMapChange<K, V>, S>.right(state);
      },
    );
  }
}
