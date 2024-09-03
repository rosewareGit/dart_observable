import '../../../../../../dart_observable.dart';
import '../../../../collections/list/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class TransformCollectListFailureImpl<E, F, CR extends CollectionState<C>, C> extends RxListFailureImpl<E, F>
    with
        BaseCollectionTransformOperator<CR, ObservableListStatefulState<E, F>, C, StateOf<ObservableListChange<E>, F>,
            StateOf<ObservableListUpdateAction<E>, F>> {
  @override
  final Observable<CR> source;

  final void Function(
    ObservableListFailure<E, F> state,
    C change,
    Emitter<StateOf<ObservableListUpdateAction<E>, F>> updater,
  ) transformFn;

  TransformCollectListFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E>, F>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
