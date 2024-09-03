import '../../../../../../dart_observable.dart';
import '../../../../collections/map/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorMapFailureImpl<K, V, F, T> extends RxMapFailureImpl<K, V, F>
    with BaseTransformOperator<T, ObservableMapStatefulState<K, V, F>, StateOf<ObservableMapUpdateAction<K, V>, F>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableMapFailure<K, V, F> state,
    T value,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
  ) transformFn;

  OperatorMapFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void handleUpdate(final StateOf<ObservableMapUpdateAction<K, V>, F> action) {
    applyAction(action);
  }

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
  ) {
    transformFn(this, value, updater);
  }
}
