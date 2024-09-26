import '../../../../dart_observable.dart';
import '../../../api/collections/collection_transforms.dart';
import 'transforms/list.dart';
import 'transforms/list_stateful.dart';
import 'transforms/map.dart';
import 'transforms/map_stateful.dart';
import 'transforms/set.dart';
import 'transforms/set_stateful.dart';

class ObservableCollectionTransformsImpl<CS extends CollectionState<C>, C>
    implements ObservableCollectionTransforms<C> {
  final Observable<CS> source;

  ObservableCollectionTransformsImpl(this.source);

  @override
  ObservableList<E> list<E>({
    required final ListChangeUpdater<E, C> transform,
    final FactoryList<E>? factory,
  }) {
    return ListChangeTransform<E, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final MapChangeUpdater<K, V, C> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return MapChangeTransform<C, CS, K, V>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final SetChangeUpdater<E, C> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return SetChangeTransform<E, C, CS>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E, S> statefulList<E, S>({
    required final StatefulListChangeUpdater<E, S, C> transform,
    final FactoryList<E>? factory,
  }) {
    return StatefulListChangeTransform<E, S, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapChangeUpdater<K, V, S, C> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionTransformMapStateful<K, V, S, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final StatefulSetChangeUpdater<E, S, C> transform,
    final FactorySet<E>? factory,
  }) {
    return StatefulSetChangeTransform<E, S, CS, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}
