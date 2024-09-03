import '../../../../../../dart_observable.dart';
import '../../../../collections/set/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class TransformSetUndefinedImpl<E2, T> extends RxSetUndefinedImpl<E2>
    with
        BaseTransformOperator<T, ObservableSetStatefulState<E2, Undefined>,
            StateOf<ObservableSetUpdateAction<E2>, Undefined>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableSetUndefined<E2> state,
    T value,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
  ) transformFn;

  TransformSetUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void handleUpdate(final StateOf<ObservableSetUpdateAction<E2>, Undefined> action) {
    applyAction(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
  ) {
    transformFn(this, value, updater);
  }
}
