import '../../../../../dart_observable.dart';
import '../../map/rx_impl.dart';
import '../_base_transform.dart';

abstract class OperatorCollectionTransformAsMap<C, CS extends CollectionState<C>, K, V> extends RxMapImpl<K, V>
    with
        BaseCollectionTransformOperator<
            CS, //
            ObservableMapState<K, V>,
            C,
            ObservableMapChange<K, V>,
            ObservableMapUpdateAction<K, V>> {
  @override
  final Observable<CS> source;

  OperatorCollectionTransformAsMap({
    required this.source,
    super.factory,
  });
}

class OperatorCollectionTransformAsMapArg<
    C, //
    CS extends CollectionState<C>,
    K,
    V> extends OperatorCollectionTransformAsMap<C, CS, K, V> {
  final MapUpdater<K, V, C> transformFn;

  OperatorCollectionTransformAsMapArg({
    required super.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  void transformChange(
    final C change,
    final Emitter<ObservableMapUpdateAction<K, V>> updater,
  ) {
    transformFn(this, change, updater);
  }
}
