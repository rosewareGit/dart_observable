import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../list/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class TransformListUndefinedImpl<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS>
    extends RxListUndefinedImpl<E2>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableListUndefined<E2>,
            CS,
            ObservableListStatefulState<E2, Undefined>,
            C,
            StateOf<ObservableListChange<E2>, Undefined>,
            StateOf<ObservableListUpdateAction<E2>, Undefined>> {
  @override
  final Self source;

  final void Function(
    ObservableListUndefined<E2> state,
    C change,
    Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
  ) transformFn;

  TransformListUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
