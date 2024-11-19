import '../../../../../dart_observable.dart';
import '../set_state.dart';

class RxStatefulSetState<E, S> extends ObservableStatefulSetState<E, S> {
  RxStatefulSetState.custom(final S custom)
      : super(
          Either<ObservableSetState<E>, S>.right(custom),
        );

  RxStatefulSetState.fromSet(final Set<E> data)
      : super(
          Either<ObservableSetState<E>, S>.left(RxSetState<E>.initial(data)),
        );

  RxStatefulSetState.fromState(final ObservableSetState<E> state)
      : super(
          Either<ObservableSetState<E>, S>.left(state),
        );
}
