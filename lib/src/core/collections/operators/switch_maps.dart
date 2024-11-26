import '../../../../dart_observable.dart';
import 'switch_maps/list.dart';
import 'switch_maps/map.dart';
import 'switch_maps/set.dart';
import 'switch_maps/stateful_list.dart';
import 'switch_maps/stateful_map.dart';
import 'switch_maps/stateful_set.dart';

class ObservableCollectionSwitchMapsImpl<T, C> implements ObservableCollectionSwitchMaps<C> {
  final ObservableCollection<T, C> source;

  ObservableCollectionSwitchMapsImpl(this.source);

  @override
  ObservableList<E> list<E>({
    required final ObservableList<E>? Function(C change) mapper,
  }) {
    return ListChangeSwitchMap<E, C, T>(
      source: source,
      mapChange: mapper,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final ObservableMap<K, V>? Function(C change) mapper,
    final FactoryMap<K, V>? factory,
  }) {
    return MapChangeSwitchMap<K, V, C, T>(
      source: source,
      mapChange: mapper,
      factory: factory,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final ObservableSet<E>? Function(C change) mapper,
    final FactorySet<E>? factory,
  }) {
    return SetChangeSwitchMap<E, C, T>(
      source: source,
      mapChange: mapper,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E, S> statefulList<E, S>({
    required final ObservableStatefulList<E, S>? Function(C change) mapper,
  }) {
    return StatefulListChangeSwitchMap<E, S, C, T>(
      source: source,
      mapChange: mapper,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final ObservableStatefulMap<K, V, S>? Function(C change) mapper,
    final FactoryMap<K, V>? factory,
  }) {
    return StatefulMapChangeSwitchMap<K, V, S, C, T>(
      source: source,
      mapChange: mapper,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final ObservableStatefulSet<E, S>? Function(C change) mapper,
    final FactorySet<E>? factory,
  }) {
    return StatefulSetChangeSwitchMap<E, S, C, T>(
      source: source,
      mapChange: mapper,
      factory: factory,
    );
  }
}
