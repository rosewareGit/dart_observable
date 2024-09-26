import '../../../../../dart_observable.dart';

class RxStatefulListState<E, S> extends ObservableStatefulListState<E, S> {
  RxStatefulListState.custom(super.custom) : super.custom();

  RxStatefulListState.fromList(final List<E> data) : super.fromList(data);

  RxStatefulListState.fromState(final ObservableListState<E> state) : super.fromState(state);
}
