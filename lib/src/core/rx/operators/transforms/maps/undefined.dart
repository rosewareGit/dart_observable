import '../../../../../../dart_observable.dart';
import '../../../../collections/map/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorMapUndefinedImpl<K, V, T> extends RxMapUndefinedImpl<K, V>
    with
        BaseTransformOperator<T, ObservableMapStatefulState<K, V, Undefined>,
            StateOf<ObservableMapUpdateAction<K, V>, Undefined>> {
  @override
  final Observable<T> source;

  final void Function(
    ObservableMapUndefined<K, V> state,
    T value,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
  ) transformFn;

  OperatorMapUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final T value,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
  ) {
    transformFn(this, value, updater);
  }

  @override
  void handleUpdate(final StateOf<ObservableMapUpdateAction<K, V>, Undefined> action) {
    applyAction(action);
  }
}
