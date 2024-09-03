import '../../../../../../dart_observable.dart';
import '../../../../collections/list/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformCollectListUndefinedFailureImpl<E, F, CS extends CollectionState<C>, C> extends RxListUndefinedFailureImpl<E, F>
    with
        BaseCollectionTransformOperator<
            CS,
            ObservableListStatefulState<E, UndefinedFailure<F>>,
            C,
            StateOf<ObservableListChange<E>, UndefinedFailure<F>>,
            StateOf<ObservableListUpdateAction<E>, UndefinedFailure<F>>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableListUndefinedFailure<E, F> state,
    C change,
    Emitter<StateOf<ObservableListUpdateAction<E>, UndefinedFailure<F>>> updater,
  ) transformFn;

  TransformCollectListUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E>? factory,
  });

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
