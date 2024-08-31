import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../map/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorMapUndefinedFailureImpl<Self extends ChangeTrackingObservable<Self, CS, C>, K, V, F, C, CS>
    extends RxMapUndefinedFailureImpl<K, V, F>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableMapUndefinedFailure<K, V, F>,
            CS,
            ObservableMapStatefulState<K, V, UndefinedFailure<F>>,
            C,
            StateOf<ObservableMapChange<K, V>, UndefinedFailure<F>>,
            StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> {
  @override
  final Self source;

  final void Function(
    ObservableMapUndefinedFailure<K, V, F> state,
    C change,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
  ) transformFn;

  OperatorMapUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
