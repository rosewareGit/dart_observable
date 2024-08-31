import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../list/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorTransformAsList<
        Self extends ChangeTrackingObservable<Self, CS, C>,
        E2, //
        C,
        CS> extends RxListImpl<E2>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableList<E2>,
            CS, //
            ObservableListState<E2>,
            C,
            ObservableListChange<E2>,
            ObservableListUpdateAction<E2>> {
  @override
  final Self source;

  OperatorTransformAsList({
    required this.source,
    super.factory,
  });
}

class OperatorTransformAsListArg<Self extends ChangeTrackingObservable<Self, CS, C>, E, C, CS>
    extends OperatorTransformAsList<Self, E, C, CS> {
  final void Function(
    ObservableList<E> state,
    C change,
    Emitter<ObservableListUpdateAction<E>> updater,
  ) transformFn;

  OperatorTransformAsListArg({
    required this.transformFn,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final C change,
    final Emitter<ObservableListUpdateAction<E>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
