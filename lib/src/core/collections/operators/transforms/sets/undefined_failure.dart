import '../../../../../../dart_observable.dart';
import '../../../../collections/set/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformCollectionSetUndefinedFailureImpl<E, F, CS extends CollectionState<C>, C>
    extends RxSetUndefinedFailureImpl<E, F>
    with
        BaseCollectionTransformOperator<
            CS,
            ObservableSetStatefulState<E, UndefinedFailure<F>>,
            C,
            StateOf<ObservableSetChange<E>, UndefinedFailure<F>>,
            StateOf<ObservableSetUpdateAction<E>, UndefinedFailure<F>>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableSetUndefinedFailure<E, F> state,
    C change,
    Emitter<StateOf<ObservableSetUpdateAction<E>, UndefinedFailure<F>>> updater,
  ) transformFn;

  TransformCollectionSetUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableSetUpdateAction<E>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
