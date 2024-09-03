import '../../../../../../dart_observable.dart';
import '../../../../collections/set/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformCollectionSetFailureImpl<F, E2, CS extends CollectionState<C>, C> extends RxSetFailureImpl<E2, F>
    with
        BaseCollectionTransformOperator<CS, ObservableSetStatefulState<E2, F>, C, StateOf<ObservableSetChange<E2>, F>,
            StateOf<ObservableSetUpdateAction<E2>, F>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableSetFailure<E2, F> state,
    C change,
    Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
  ) transformFn;

  TransformCollectionSetFailureImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E2>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableSetUpdateAction<E2>, F>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
