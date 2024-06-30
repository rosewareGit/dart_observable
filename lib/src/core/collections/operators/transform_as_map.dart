part of '../map/map.dart';

abstract class OperatorCollectionsTransformAsMap<E, C, T extends CollectionState<E, C>, K, V> extends RxMapImpl<K, V>
    with
        BaseCollectionTransformOperator<
            E, //
            K,
            C,
            T,
            ObservableMapChange<K, V>,
            ObservableMapState<K, V>,
            ObservableMap<K, V>,
            ObservableMapUpdateAction<K, V>> {
  @override
  final ObservableCollection<E, C, T> source;

  OperatorCollectionsTransformAsMap({
    required this.source,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  ObservableMap<K, V> get current => this;
}

class OperatorCollectionsTransformAsMapArg<E, C, T extends CollectionState<E, C>, K, V>
    extends OperatorCollectionsTransformAsMap<E, C, T, K, V> {
  final MapUpdater<K, V, C> transformFn;

  OperatorCollectionsTransformAsMapArg({
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
