import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../map/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorMapFailureImpl<Self extends ChangeTrackingObservable<Self, CS, C>, K, V, F, C, CS>
    extends RxMapFailureImpl<K, V, F>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableMapFailure<K, V, F>,
            CS, //
            ObservableMapStatefulState<K, V, F>,
            C,
            StateOf<ObservableMapChange<K, V>, F>,
            StateOf<ObservableMapUpdateAction<K, V>, F>> {
  @override
  final Self source;

  final void Function(
    ObservableMapFailure<K, V, F> state,
    C change,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
  ) transformFn;

  OperatorMapFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
