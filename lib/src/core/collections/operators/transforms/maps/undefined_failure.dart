import '../../../../../../dart_observable.dart';
import '../../../../collections/map/stateful/undefined_failure/rx_impl.dart';
import '../../_base_transform.dart';

class OperatorCollectionMapUndefinedFailureImpl<K, V, F, CS extends CollectionState<C>, C>
    extends RxMapUndefinedFailureImpl<K, V, F>
    with
        BaseCollectionTransformOperator<
            CS,
            ObservableMapStatefulState<K, V, UndefinedFailure<F>>,
            C,
            StateOf<ObservableMapChange<K, V>, UndefinedFailure<F>>,
            StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> {
  @override
  final Observable<CS> source;

  final void Function(
    ObservableMapUndefinedFailure<K, V, F> state,
    C change,
    Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
  ) transformFn;

  OperatorCollectionMapUndefinedFailureImpl({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<StateOf<ObservableMapUpdateAction<K, V>, UndefinedFailure<F>>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
