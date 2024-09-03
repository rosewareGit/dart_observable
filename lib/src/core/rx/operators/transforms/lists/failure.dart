import '../../../../../../dart_observable.dart';
import '../../../../collections/list/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformListFailureImpl<T, E, F> extends RxListFailureImpl<E, F>
    with BaseTransformOperator<T, ObservableListStatefulState<E, F>, StateOf<ObservableListUpdateAction<E>, F>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableListFailure<E, F> state,
    T value,
    Emitter<StateOf<ObservableListUpdateAction<E>, F>> updater,
  ) transformFn;

  TransformListFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E>? factory,
  }) : super(factory: factory);

  @override
  void handleUpdate(final StateOf<ObservableListUpdateAction<E>, F> action) {
    applyAction(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableListUpdateAction<E>, F>> updater,
  ) {
    transformFn(this, value, updater);
  }
}
