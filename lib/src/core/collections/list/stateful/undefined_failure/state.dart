import '../../../../../../dart_observable.dart';
import '../../list_state.dart';
import '../state.dart';

class RxListUndefinedFailureState<E, F> extends RxListStatefulState<E, UndefinedFailure<F>> {
  factory RxListUndefinedFailureState.data(final List<E> data) {
    return RxListUndefinedFailureState<E, F>._data(RxListState<E>.initial(data));
  }

  factory RxListUndefinedFailureState.failure(final F failure) {
    return RxListUndefinedFailureState<E, F>._custom(UndefinedFailure<F>.failure(failure));
  }

  factory RxListUndefinedFailureState.undefined() {
    return RxListUndefinedFailureState<E, F>._custom(UndefinedFailure<F>.undefined());
  }

  const RxListUndefinedFailureState._custom(final UndefinedFailure<F> state) : super.custom(state);

  const RxListUndefinedFailureState._data(final ObservableListState<E> state) : super.data(state);

  R foldState<R>({
    required final R Function(ObservableListState<E> state) onData,
    required final R Function() onUndefined,
    required final R Function(F failure) onFailure,
  }) {
    return fold(
      onData: onData,
      onCustom: (final UndefinedFailure<F> state) {
        return state.fold(
          onUndefined: onUndefined,
          onFailure: onFailure,
        );
      },
    );
  }
}
