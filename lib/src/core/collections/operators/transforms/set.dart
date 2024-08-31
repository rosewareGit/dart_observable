import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../set/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorTransformAsSet<
        Self extends ChangeTrackingObservable<Self, CS, C>,
        E2, //
        C,
        CS> extends RxSetImpl<E2>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableSet<E2>,
            CS, //
            ObservableSetState<E2>,
            C,
            ObservableSetChange<E2>,
            ObservableSetUpdateAction<E2>> {
  @override
  final Self source;

  OperatorTransformAsSet({
    required this.source,
    super.factory,
  });
}

class OperatorTransformAsSetArg<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS>
    extends OperatorTransformAsSet<Self, E2, C, CS> {
  final void Function(
    ObservableSet<E2> state,
    C change,
    Emitter<ObservableSetUpdateAction<E2>> updater,
  ) transformFn;

  OperatorTransformAsSetArg({
    required super.source,
    required this.transformFn,
    super.factory,
  });

  @override
  void transformChange(
    final C change,
    final Emitter<ObservableSetUpdateAction<E2>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
