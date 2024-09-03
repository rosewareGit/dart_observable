import '../../../../../../dart_observable.dart';
import '../../../../collections/set/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformSetUndefinedFailureImpl<E2, F, T> extends RxSetUndefinedFailureImpl<E2, F>
    with
        BaseTransformOperator<T, ObservableSetStatefulState<E2, UndefinedFailure<F>>,
            StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableSetUndefinedFailure<E2, F> state,
    T value,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) transformFn;

  TransformSetUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void handleUpdate(final StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>> action) {
    applyAction(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, value, updater);
  }
}
