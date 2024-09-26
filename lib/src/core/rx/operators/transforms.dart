import '../../../../dart_observable.dart';
import 'transforms/list.dart';
import 'transforms/list_stateful.dart';
import 'transforms/map.dart';
import 'transforms/map_stateful.dart';
import 'transforms/set.dart';
import 'transforms/set_stateful.dart';

class ObservableTransformsImpl<T> implements ObservableTransforms<T> {
  final Observable<T> source;

  ObservableTransformsImpl(this.source);

  @override
  ObservableList<E> list<E>({
    required final ListUpdater<E, T> transform,
    final FactoryList<E>? factory,
  }) {
    return ListTransform<T, E>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final MapUpdater<K, V, T> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return MapTransform<T, K, V>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final SetUpdater<E, T> transform,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return SetTransform<T, E>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E, S> statefulList<E, S>({
    required final StatefulListUpdater<E, S, T> transform,
    final FactoryList<E>? factory,
  }) {
    return StatefulListTransform<T, E, S>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final StatefulMapUpdater<K, V, S, T> transform,
    final FactoryMap<K, V>? factory,
  }) {
    return StatefulMapTransform<T, K, V, S>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final StatefulSetUpdater<E, S, T> transform,
    final FactorySet<E>? factory,
  }) {
    return StatefulSetTransform<T, E, S>(
      source: source,
      transformFn: transform,
      factory: factory,
    );
  }
}
