part of '../../map/map.dart';

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
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  ObservableMap<K, V> get current => this;
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
  ObservableMap<K, V> get current => this;

  @override
  void transformChange(
    final ObservableMap<K, V> state,
    final C change,
    final Emitter<ObservableMapUpdateAction<K, V>> updater,
  ) {
    transformFn(state, change, updater);
  }
}
