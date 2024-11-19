import '../../../../../dart_observable.dart';
import '../../../../core/collections/map/stateful/state.dart';

abstract class ObservableStatefulMapState<K, V, S> extends ObservableCollectionState<ObservableMapState<K, V>, S> {
  ObservableStatefulMapState(final Either<ObservableMapState<K, V>, S> state) : super(state);

  factory ObservableStatefulMapState.custom(final S custom) {
    return RxStatefulMapState<K, V, S>.custom(custom);
  }

  factory ObservableStatefulMapState.fromMap(final Map<K, V> data) {
    return RxStatefulMapState<K, V, S>.fromMap(data);
  }

  factory ObservableStatefulMapState.fromState(final ObservableMapState<K, V> state) {
    return RxStatefulMapState<K, V, S>.fromState(state);
  }
}
