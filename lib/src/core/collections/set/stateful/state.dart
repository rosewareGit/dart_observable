import '../../../../../dart_observable.dart';

class RxStatefulSetState<E, S> extends ObservableStatefulSetState<E, S> {
  RxStatefulSetState.custom(super.custom) : super.custom();

  RxStatefulSetState.fromSet(final Set<E> data) : super.fromSet(data);

  RxStatefulSetState.fromState(final ObservableSetState<E> state) : super.fromState(state);
}
