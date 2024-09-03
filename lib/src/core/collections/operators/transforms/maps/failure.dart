import '../../../../../../dart_observable.dart';
import '../../../../collections/map/stateful/failure/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorCollectMapFailureImpl<K, V, F, CS extends CollectionState<C>, C> extends RxMapFailureImpl<K, V, F>
    with
        BaseCollectionTransformOperator<CS, ObservableMapStatefulState<K, V, F>, C,
            StateOf<ObservableMapChange<K, V>, F>, StateOf<ObservableMapUpdateAction<K, V>, F>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableMapFailure<K, V, F> state,
    C change,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
  ) transformFn;

  OperatorCollectMapFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, F>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
