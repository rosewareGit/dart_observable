import '../../../../../dart_observable.dart';
import '../map_state.dart';

class RxStatefulMapState<K, V, S> extends ObservableStatefulMapState<K, V, S> {
  RxStatefulMapState.custom(final S custom)
      : super(
          Either<ObservableMapState<K, V>, S>.right(custom),
        );

  RxStatefulMapState.fromMap(final Map<K, V> data)
      : super(
          Either<ObservableMapState<K, V>, S>.left(RxMapState<K, V>.initial(data)),
        );

  RxStatefulMapState.fromState(final ObservableMapState<K, V> state)
      : super(
          Either<ObservableMapState<K, V>, S>.left(state),
        );
}
