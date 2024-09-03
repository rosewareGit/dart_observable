import '../../../../../dart_observable.dart';
import '../../set/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorCollectionTransformAsSet<
        E2, //
        C,
        CS extends CollectionState<C>> extends RxSetImpl<E2>
    with
        BaseCollectionTransformOperator<
            CS, //
            ObservableSetState<E2>,
            C,
            ObservableSetChange<E2>,
            ObservableSetUpdateAction<E2>> {
  @override
  final Observable<CS> source;

  OperatorCollectionTransformAsSet({
    required this.source,
    super.factory,
  });
}

class OperatorCollectionTransformAsSetArg<E2, C, CS extends CollectionState<C>>
    extends OperatorCollectionTransformAsSet<E2, C, CS> {
  final void Function(
    ObservableSet<E2> state,
    C change,
    Emitter<ObservableSetUpdateAction<E2>> updater,
  ) transformFn;

  OperatorCollectionTransformAsSetArg({
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
