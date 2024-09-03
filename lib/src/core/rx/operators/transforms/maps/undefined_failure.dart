import '../../../../../../dart_observable.dart';
import '../../../../collections/map/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorMapUndefinedFailureImpl<K, V, F, T> extends RxMapUndefinedFailureImpl<K, V, F>
    with
        BaseTransformOperator<T, ObservableMapStatefulState<K, V, UndefinedFailure<F>>,
            StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableMapUndefinedFailure<K, V, F> state,
    T value,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
  ) transformFn;

  OperatorMapUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void handleUpdate(final StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>> action) {
    applyAction(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, value, updater);
  }
}
