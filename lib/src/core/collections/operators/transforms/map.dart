part of '../../map/rx_impl.dart';

abstract class OperatorTransformAsMap<Self extends ChangeTrackingObservable<Self, CS, C>, C, CS, K, V>
    extends RxMapImpl<K, V>
    with
        BaseCollectionTransformOperator<
            Self,
            ObservableMap<K, V>,
            CS, //
            ObservableMapState<K, V>,
            C,
            ObservableMapChange<K, V>,
            ObservableMapUpdateAction<K, V>> {
  @override
  final Self source;

  OperatorTransformAsMap({
    required this.source,
    super.factory,
  });
}

class OperatorTransformAsMapArg<
    Self extends ChangeTrackingObservable<Self, CS, C>,
    C, //
    CS,
    K,
    V> extends OperatorTransformAsMap<Self, C, CS, K, V> {
  final MapUpdater<K, V, C> transformFn;

  OperatorTransformAsMapArg({
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
