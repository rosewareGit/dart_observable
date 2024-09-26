import '../../../../../dart_observable.dart';
import '../../../../core/collections/map/stateful/rx_stateful.dart';
import '../rx_actions.dart';

abstract interface class RxStatefulMap<K, V, S> implements ObservableStatefulMap<K, V, S>, RxMapActions<K, V> {
  factory RxStatefulMap({
    final S? custom,
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) {
    if (custom != null) {
      return RxStatefulMapImpl<K, V, S>.custom(
        custom,
        factory: factory,
      );
    }

    return RxStatefulMapImpl<K, V, S>(
      initial ?? <K, V>{},
      factory: factory,
    );
  }

  factory RxStatefulMap.custom(
    final S state, {
    final FactoryMap<K, V>? factory,
  }) {
    return RxStatefulMapImpl<K, V, S>.custom(
      state,
      factory: factory,
    );
  }

  Either<ObservableMapChange<K, V>, S>? applyAction(
    final Either<ObservableMapUpdateAction<K, V>, S> action,
  );

  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action);

  Either<ObservableMapChange<K, V>, S>? setState(final S newState);
}
