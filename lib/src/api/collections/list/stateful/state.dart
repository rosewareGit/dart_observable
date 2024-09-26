import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/list_state.dart';

abstract class ObservableStatefulListState<E, S>
    extends ObservableCollectionState<ObservableListState<E>, ObservableListChange<E>, S> {
  ObservableStatefulListState.custom(final S custom) : super.custom(custom);

  ObservableStatefulListState.fromList(final List<E> data) : super.data(RxListState<E>.initial(data));

  ObservableStatefulListState.fromState(final ObservableListState<E> state) : super.data(state);
}
