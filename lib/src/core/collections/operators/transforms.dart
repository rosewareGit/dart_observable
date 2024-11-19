import '../../../../dart_observable.dart';
import '../../../api/collections/collection_transforms.dart';
import 'transforms/list.dart';
import 'transforms/list_stateful.dart';
import 'transforms/map.dart';
import 'transforms/map_stateful.dart';
import 'transforms/set.dart';
import 'transforms/set_stateful.dart';

class ObservableCollectionTransformsImpl<T, C> implements ObservableCollectionTransforms<C> {
  final ObservableCollection<T, C> source;

  ObservableCollectionTransformsImpl(this.source);

  @override
  ObservableList<E> list<E>({
    required final ListChangeUpdater<E, C> transform,
  }) {
    return ListChangeTransform<E, C, T>(
      source: source,
      transformFn: transform,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final MapChangeUpdater<K, V, C> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return MapChangeTransform<C, T, K, V>(
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
    return SetChangeTransform<E, C, T>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E, S> statefulList<E, S>({
    required final StatefulListChangeUpdater<E, S, C> transform,
  }) {
    return StatefulListChangeTransform<E, S, T, C>(
      source: source,
      transformFn: transform,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapChangeUpdater<K, V, S, C> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return OperatorCollectionTransformMapStateful<K, V, S, T, C>(
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
    return StatefulSetChangeTransform<E, S, T, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}
