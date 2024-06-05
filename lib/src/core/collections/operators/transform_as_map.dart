part of '../map/map.dart';

class OperatorCollectionsTransformAsMap<E, C, T extends CollectionState<E, C>, K, V> extends RxMapImpl<K, V>
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

  @override
  final void Function(
    ObservableMap<K, V> state,
    C change,
    Emitter<ObservableMapUpdateAction<K, V>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsMap({
    required this.source,
    required this.transformFn,
    final FactoryMap<K, V>? factory,
  }) : super(factory: factory);

  @override
  ObservableMap<K, V> get current => this;
}
