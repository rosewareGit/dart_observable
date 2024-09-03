import '../../../../../../dart_observable.dart';
import '../../../../collections/list/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class TransformListUndefinedImpl<T, E2> extends RxListUndefinedImpl<E2>
    with
        BaseTransformOperator<T, ObservableListStatefulState<E2, Undefined>,
            StateOf<ObservableListUpdateAction<E2>, Undefined>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableListUndefined<E2> state,
    T value,
    Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
  ) transformFn;

  TransformListUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
  ) {
    transformFn(this, value, updater);
  }

  @override
  void handleUpdate(final StateOf<ObservableListUpdateAction<E2>, Undefined> action) {
    applyAction(action);
  }
}
