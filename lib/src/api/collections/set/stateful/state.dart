import '../../../../../dart_observable.dart';
import '../../../../core/collections/set/set_state.dart';

abstract class ObservableStatefulSetState<E, S>
    extends ObservableCollectionState<ObservableSetState<E>, ObservableSetChange<E>, S> {
  ObservableStatefulSetState.custom(final S custom) : super.custom(custom);

  ObservableStatefulSetState.fromSet(final Set<E> data) : super.data(RxSetState<E>.initial(data));

  ObservableStatefulSetState.fromState(final ObservableSetState<E> state) : super.data(state);
}
