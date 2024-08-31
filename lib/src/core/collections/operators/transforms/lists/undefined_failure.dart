import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../list/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformListUndefinedFailureImpl<Self extends ChangeTrackingObservable<Self, CS, C>, E2, F, C, CS>
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

  TransformListUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E2>? factory,
  });

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
