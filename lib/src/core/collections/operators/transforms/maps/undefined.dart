import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../map/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorMapUndefinedImpl<Self extends ChangeTrackingObservable<Self, CS, C>, K, V, C, CS>
    extends RxMapUndefinedImpl<K, V>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableMapUndefined<K, V>,
            CS,
            ObservableMapStatefulState<K, V, Undefined>,
            C,
            StateOf<ObservableMapChange<K, V>, Undefined>,
            StateOf<ObservableMapUpdateAction<K, V>, Undefined>> {
  @override
  final Self source;

  final void Function(
    ObservableMapUndefined<K, V> state,
    C change,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, Undefined>> updater,
  ) transformFn;

  OperatorMapUndefinedImpl({
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
