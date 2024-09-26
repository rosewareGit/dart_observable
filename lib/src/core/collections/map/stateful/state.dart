import '../../../../../dart_observable.dart';

class RxStatefulMapState<K, V, S> extends ObservableStatefulMapState<K, V, S> {
  RxStatefulMapState.custom(super.custom) : super.custom();

  RxStatefulMapState.fromMap(final Map<K, V> data) : super.fromMap(data);

  RxStatefulMapState.fromState(final ObservableMapState<K, V> state) : super.fromState(state);
}
