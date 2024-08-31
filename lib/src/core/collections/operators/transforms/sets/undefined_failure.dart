import '../../../../../../dart_observable.dart';
import '../../../../../api/change_tracking_observable.dart';
import '../../../set/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformSetUndefinedFailureImpl<Self extends ChangeTrackingObservable<Self, CS, C>, E2, F, C, CS>
    extends RxSetUndefinedFailureImpl<E2, F>
    with
        BaseCollectionTransformOperator<
            Self, //
            ObservableSetUndefinedFailure<E2, F>,
            CS,
            ObservableSetStatefulState<E2, UndefinedFailure<F>>,
            C,
            StateOf<ObservableSetChange<E2>, UndefinedFailure<F>>,
            StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> {
  @override
  final Self source;

  final void Function(
    ObservableSetUndefinedFailure<E2, F> state,
    C change,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) transformFn;

  TransformSetUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
