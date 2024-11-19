import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/stateful/state.dart';

abstract class ObservableStatefulListState<E, S> extends ObservableCollectionState<ObservableListState<E>, S> {
  ObservableStatefulListState(final Either<ObservableListState<E>, S> state) : super(state);

  factory ObservableStatefulListState.custom(final S custom) {
    return RxStatefulListState<E, S>.custom(custom);
  }

  factory ObservableStatefulListState.fromList(final List<E> data) {
    return RxStatefulListState<E, S>.fromList(data);
  }
}
