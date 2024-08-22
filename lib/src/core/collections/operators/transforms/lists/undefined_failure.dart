import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../list/stateful/undefined_failure/list.dart';
import '../../_base_transform.dart';

class OperatorCollectionsTransformAsOptionalResult<Self extends ChangeTrackingObservable<Self, CS, C>, E2, F, C, CS>
    extends RxListUndefinedFailureImpl<E2, F>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableListUndefinedFailure<E2, F>,
            CS,
            ObservableListStatefulState<E2, UndefinedFailure<F>>,
            C,
            StateOf<ObservableListChange<E2>, UndefinedFailure<F>>,
            StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> {
  @override
  final Self source;

  final void Function(
    ObservableListUndefinedFailure<E2, F> state,
    C change,
    Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsOptionalResult({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  }) : super(factory: factory);

  @override
  ObservableListUndefinedFailure<E2, F> get current => this;

  @override
  void transformChange(
    final ObservableListUndefinedFailure<E2, F> state,
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(state, change, updater);
  }
}
