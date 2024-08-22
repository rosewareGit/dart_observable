import '../../../../../dart_observable.dart';
import '../../../rx/base_tracking.dart';
import '../../_base.dart';
import '../map.dart';
import '../map_state.dart';
import '../rx_actions.dart';
import 'state.dart';

abstract class RxMapStatefulImpl<Self extends ObservableMapStateful<Self, K, V, S>, K, V, S>
    extends RxBaseTracking<Self, ObservableMapStatefulState<K, V, S>, StateOf<ObservableMapChange<K, V>, S>>
    with
        ObservableCollectionBase<
            Self,
            K, //
            StateOf<ObservableMapChange<K, V>, S>,
            ObservableMapStatefulState<K, V, S>>,
        RxMapActionsImpl<K, V>
    implements
        RxMapStateful<Self, K, V, S> {
  final FactoryMap<K, V> _factory;

  RxMapStatefulImpl(
    super.value, {
    final FactoryMap<K, V>? factory,
  }) : _factory = factory ?? defaultMapFactory<K, V>();

  @override
  Map<K, V>? get data => value.fold(
        onData: (final ObservableMapState<K, V> data) => data.mapView,
        onCustom: (final _) => null,
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

  @override
  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action) {
    return applyAction(
      StateOf<ObservableMapUpdateAction<K, V>, S>.data(action),
    )?.data;
  }

  @override
  StateOf<int, S> get length => value.fold(
        onData: (final ObservableMapState<K, V> data) => StateOf<int, S>.data(data.mapView.length),
        onCustom: (final S state) => StateOf<int, S>.custom(state),
      );

  @override
  int? get lengthOrNull => length.data;

  @override
  StateOf<ObservableMapChange<K, V>, S>? setState(final S newState) {
    return applyAction(StateOf<ObservableMapUpdateAction<K, V>, S>.custom(newState));
  }

  @override
  Observable<StateOf<V?, S>> rxItem(final K key) {
    // TODO
    throw UnimplementedError();
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
}
