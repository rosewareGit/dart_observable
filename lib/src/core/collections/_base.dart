import '../../../dart_observable.dart';
import 'map/map.dart';
import 'map/result.dart';
import 'operators/flatmap_as_map.dart';
import 'operators/flatmap_as_set.dart';
import 'operators/transform_as_set.dart';
import 'operators/transform_as_set_result.dart';

mixin ObservableCollectionBase<E, C, T extends CollectionState<E, C>> on Observable<T>
    implements ObservableCollection<E, C, T> {
  @override
  ObservableSet<E2> flatMapCollectionAsSet<E2>({
    required final ObservableCollectionFlatMapUpdate<E, E2, ObservableSet<E2>> Function(C change) sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) {
    return OperatorCollectionsFlatMapAsSet<E, E2, C, T>(
      source: this,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> flatMapCollectionAsMap<K, V>({
    required final ObservableCollectionFlatMapUpdate<E, K, ObservableMap<K, V>> Function(C change) sourceProvider,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionsFlatMapAsMap<E, K, V, C, T>(
      source: this,
      sourceProvider: sourceProvider,
      factory: factory,
    );
  }

  @override
  ObservableMap<K2, V2> transformCollectionAsMap<K2, V2>({
    required final void Function(
      C change,
      Emitter<ObservableMapUpdateAction<K2, V2>> updater,
    ) transform,
    final FactoryMap<K2, V2>? factory,
  }) {
    return OperatorCollectionsTransformAsMap<E, C, T, K2, V2>(
      source: this,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMapResult<K2, V2, F> transformCollectionAsMapResult<K2, V2, F>({
    required final void Function(
      C change,
      Emitter<ObservableMapResultUpdateAction<K2, V2, F>> updater,
    ) transform,
    final FactoryMap<K2, V2>? factory,
  }) {
    return OperatorCollectionsTransformAsMapResult<E, C, T, K2, V2, F>(
      source: this,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSet<E2> transformCollectionAsSet<E2>({
    required final void Function(
      C change,
      Emitter<ObservableSetUpdateAction<E2>> updater,
    ) transform,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) {
    return OperatorCollectionsTransformAsSet<E, E2, C, T>(
      source: this,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSetResult<E2, F> transformCollectionAsSetResult<E2, F>({
    required final void Function(
      ObservableSetResult<E2, F> state,
      C change,
      Emitter<ObservableSetResultUpdateAction<E2, F>> updater,
    ) transform,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) {
    return OperatorCollectionsTransformAsSetResult<E, E2, F, C, T>(
      source: this,
      transformFn: transform,
      factory: factory,
    );
  }
}
