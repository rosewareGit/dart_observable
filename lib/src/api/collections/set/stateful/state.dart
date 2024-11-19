import '../../../../../dart_observable.dart';
import '../../../../core/collections/set/stateful/state.dart';

abstract class ObservableStatefulSetState<E, S> extends ObservableCollectionState<ObservableSetState<E>, S> {
  ObservableStatefulSetState(final Either<ObservableSetState<E>, S> state) : super(state);

  factory ObservableStatefulSetState.custom(final S custom) {
    return RxStatefulSetState<E, S>.custom(custom);
  }

  factory ObservableStatefulSetState.fromSet(final Set<E> data) {
    return RxStatefulSetState<E, S>.fromSet(data);
  }

  factory ObservableStatefulSetState.fromState(final ObservableSetState<E> state) {
    return RxStatefulSetState<E, S>.fromState(state);
  }
}
