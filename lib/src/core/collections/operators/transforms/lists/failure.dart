import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../list/stateful/failure/list.dart';
import '../../_base_transform.dart';

class OperatorCollectionsTransformAsResult<Self extends ChangeTrackingObservable<Self, CS, C>, F, E2, C, CS>
    extends RxListFailureImpl<E2, F>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableListFailure<E2, F>,
            CS, //
            ObservableListStatefulState<E2, F>,
            C,
            StateOf<ObservableListChange<E2>, F>,
            StateOf<ObservableListUpdateAction<E2>, F>> {
  @override
  final Self source;

  final void Function(
    ObservableListFailure<E2, F> state,
    C change,
    Emitter<StateOf<ObservableListUpdateAction<E2>, F>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsResult({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  ObservableListFailure<E2, F> get current => this;

  @override
  void transformChange(
    final ObservableListFailure<E2, F> state,
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, F>> updater,
  ) {
    transformFn(state, change, updater);
  }
}
