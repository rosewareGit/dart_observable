import '../../../../../dart_observable.dart';
import '../../../../core/collections/map/map_state.dart';

abstract class ObservableStatefulMapState<K, V, S>
    extends ObservableCollectionState<ObservableMapState<K, V>, ObservableMapChange<K, V>, S> {
  ObservableStatefulMapState.custom(final S custom) : super.custom(custom);

  ObservableStatefulMapState.fromMap(final Map<K, V> data) : super.data(RxMapState<K, V>.initial(data));

  ObservableStatefulMapState.fromState(final ObservableMapState<K, V> state) : super.data(state);
}
