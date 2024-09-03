import '../../../../../../dart_observable.dart';
import '../../../../collections/set/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformSetFailureImpl<F, E2, T> extends RxSetFailureImpl<E2, F>
    with BaseTransformOperator<T, ObservableSetStatefulState<E2, F>, StateOf<ObservableSetUpdateAction<E2>, F>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableSetFailure<E2, F> state,
    T value,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
  ) transformFn;

  TransformSetFailureImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void handleUpdate(final StateOf<ObservableSetUpdateAction<E2>, F> action) {
    applyAction(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
  ) {
    transformFn(this, value, updater);
  }
}
