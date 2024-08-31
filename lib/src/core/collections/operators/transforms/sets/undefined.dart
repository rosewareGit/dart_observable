import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../set/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class TransformSetUndefinedImpl<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS> extends RxSetUndefinedImpl<E2>
    with
        BaseCollectionTransformOperator<
            Self, //
            ObservableSetUndefined<E2>,
            CS,
            ObservableSetStatefulState<E2, Undefined>,
            C,
            StateOf<ObservableSetChange<E2>, Undefined>,
            StateOf<ObservableSetUpdateAction<E2>, Undefined>> {
  @override
  final Self source;

  final void Function(
    ObservableSetUndefined<E2> state,
    C change,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
  ) transformFn;

  TransformSetUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, Undefined>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
