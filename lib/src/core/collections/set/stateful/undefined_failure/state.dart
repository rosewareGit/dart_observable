import '../../../../../../dart_observable.dart';
import '../../set_state.dart';
import '../state.dart';

class RxSetUndefinedFailureState<E, F> extends RxSetStatefulState<E, UndefinedFailure<F>> {
  factory RxSetUndefinedFailureState.data(final Set<E> data) {
    return RxSetUndefinedFailureState<E, F>._data(RxSetState<E>.initial(data));
  }

  factory RxSetUndefinedFailureState.failure(final F failure) {
    return RxSetUndefinedFailureState<E, F>._custom(UndefinedFailure<F>.failure(failure));
  }

  factory RxSetUndefinedFailureState.undefined() {
    return RxSetUndefinedFailureState<E, F>._custom(UndefinedFailure<F>.undefined());
  }

  const RxSetUndefinedFailureState._custom(final UndefinedFailure<F> state) : super.custom(state);

  const RxSetUndefinedFailureState._data(final ObservableSetState<E> state) : super.data(state);
}
