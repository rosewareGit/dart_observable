import '../../../../../../dart_observable.dart';
import '../../../../collections/list/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class TransformCollectListUndefinedImpl<E, CS extends CollectionState<C>, C> extends RxListUndefinedImpl<E>
    with
        BaseCollectionTransformOperator<CS, ObservableListStatefulState<E, Undefined>, C,
            StateOf<ObservableListChange<E>, Undefined>, StateOf<ObservableListUpdateAction<E>, Undefined>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableListUndefined<E> state,
    C change,
    Emitter<StateOf<ObservableListUpdateAction<E>, Undefined>> updater,
  ) transformFn;

  TransformCollectListUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactoryList<E>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableListUpdateAction<E>, Undefined>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
