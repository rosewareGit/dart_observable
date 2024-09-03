import '../../../../../../dart_observable.dart';
import '../../../../collections/map/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorCollectMapUndefinedImpl<K, V, CS extends CollectionState<C>, C> extends RxMapUndefinedImpl<K, V>
    with
        BaseCollectionTransformOperator<CS, ObservableMapStatefulState<K, V, Undefined>, C,
            StateOf<ObservableMapChange<K, V>, Undefined>, StateOf<ObservableMapUpdateAction<K, V>, Undefined>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableMapUndefined<K, V> state,
    C change,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
  ) transformFn;

  OperatorCollectMapUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
