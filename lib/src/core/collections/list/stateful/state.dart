import '../../../../../dart_observable.dart';
import '../list_state.dart';

class RxStatefulListState<E, S> extends ObservableStatefulListState<E, S> {
  RxStatefulListState.custom(final S custom)
      : super(
          Either<ObservableListState<E>, S>.right(custom),
        );

  RxStatefulListState.fromList(final List<E> data)
      : super(
          Either<ObservableListState<E>, S>.left(RxListState<E>.fromData(data)),
        );

  RxStatefulListState.fromState(final ObservableListState<E> state)
      : super(Either<ObservableListState<E>, S>.left(state));
}
