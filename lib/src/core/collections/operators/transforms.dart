import '../../../../dart_observable.dart';
import '../../../api/collections/collection_transforms.dart';
import 'transforms/list.dart';
import 'transforms/list_stateful.dart';
import 'transforms/map.dart';
import 'transforms/map_stateful.dart';
import 'transforms/set.dart';
import 'transforms/set_stateful.dart';

class ObservableCollectionTransformsImpl<T, C> implements ObservableCollectionTransforms<C, T> {
  final ObservableCollection<T, C> source;

  ObservableCollectionTransformsImpl(this.source);

  @override
  ObservableList<E> list<E>({
    required final ListChangeUpdater<E, C, T> transform,
  }) {
    return ListChangeTransform<E, T, C>(
      source: source,
      transformFn: transform,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final MapChangeUpdater<K, V, C, T> transform,
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
    required final SetChangeUpdater<E, C, T> transform,
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
    required final StatefulListChangeUpdater<E, S, C, T> transform,
  }) {
    return StatefulListChangeTransform<E, S, T, C>(
      source: source,
      transformFn: transform,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapChangeUpdater<K, V, S, C, T> transform,
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
    required final StatefulSetChangeUpdater<E, S, C, T> transform,
    final FactorySet<E>? factory,
  }) {
    return StatefulSetChangeTransform<E, S, T, C>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}
