import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../list/stateful/undefined/list.dart';
import '../../_base_transform.dart';

class OperatorCollectionsTransformAsUndefined<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS>
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

  OperatorCollectionsTransformAsUndefined({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  ObservableListUndefined<E2> get current => this;

  @override
  void transformChange(
    final ObservableListUndefined<E2> state,
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, Undefined>> updater,
  ) {
    transformFn(state, change, updater);
  }
}
