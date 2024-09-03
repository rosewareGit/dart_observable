import '../../../../../../dart_observable.dart';
import '../../../../collections/list/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformListUndefinedFailureImpl<T, E2, F> extends RxListUndefinedFailureImpl<E2, F>
    with
        BaseTransformOperator<T, ObservableListStatefulState<E2, UndefinedFailure<F>>,
            StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableListUndefinedFailure<E2, F> state,
    T value,
    Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) transformFn;

  TransformListUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  });

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, value, updater);
  }

  @override
  void handleUpdate(final StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>> action) {
    applyAction(action);
  }
}
