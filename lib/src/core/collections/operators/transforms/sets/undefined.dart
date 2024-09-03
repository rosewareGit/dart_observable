import '../../../../../../dart_observable.dart';
import '../../../../collections/set/stateful/undefined/rx_impl.dart';
import '../../_base_transform.dart';

class TransformCollectionSetUndefinedImpl<E, CS extends CollectionState<C>, C> extends RxSetUndefinedImpl<E>
    with
        BaseCollectionTransformOperator<CS, ObservableSetStatefulState<E, Undefined>, C,
            StateOf<ObservableSetChange<E>, Undefined>, StateOf<ObservableSetUpdateAction<E>, Undefined>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableSetUndefined<E> state,
    C change,
    Emitter<StateOf<ObservableSetUpdateAction<E>, Undefined>> updater,
  ) transformFn;

  TransformCollectionSetUndefinedImpl({
    required this.source,
    required this.transformFn,
    final FactorySet<E>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableSetUpdateAction<E>, Undefined>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
