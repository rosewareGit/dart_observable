import '../../../../../../dart_observable.dart';
import '../../map_state.dart';
import '../state.dart';

class RxMapUndefinedFailureState<K, V, F> extends RxMapStatefulState<K, V, UndefinedFailure<F>> {
  factory RxMapUndefinedFailureState.data(final Map<K, V> data) {
    return RxMapUndefinedFailureState<K, V, F>._data(RxMapState<K, V>.initial(data));
  }

  factory RxMapUndefinedFailureState.failure(final F failure) {
    return RxMapUndefinedFailureState<K, V, F>._custom(UndefinedFailure<F>.failure(failure));
  }

  factory RxMapUndefinedFailureState.undefined() {
    return RxMapUndefinedFailureState<K, V, F>._custom(UndefinedFailure<F>.undefined());
  }

  const RxMapUndefinedFailureState._custom(final UndefinedFailure<F> state) : super.custom(state);

  const RxMapUndefinedFailureState._data(final ObservableMapState<K, V> state) : super.data(state);
}
