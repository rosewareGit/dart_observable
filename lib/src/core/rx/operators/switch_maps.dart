import '../../../../dart_observable.dart';
import 'switch_maps/list.dart';
import 'switch_maps/list_stateful.dart';
import 'switch_maps/map.dart';
import 'switch_maps/map_stateful.dart';
import 'switch_maps/set.dart';
import 'switch_maps/set_stateful.dart';

class ObservableSwitchMapsImpl<T> implements ObservableSwitchMaps<T> {
  final Observable<T> source;

  ObservableSwitchMapsImpl(this.source);

  @override
  ObservableList<E> list<E>({
    required final ObservableList<E> Function(T value) mapper,
  }) {
    return ListSwitchMap<E, T>(
      source: source,
      mapper: mapper,
    );
  }

  @override
  ObservableMap<K, V> map<K, V>({
    required final ObservableMap<K, V> Function(T value) mapper,
    final FactoryMap<K, V>? factory,
  }) {
    return MapSwitchMap<K, V, T>(
      source: source,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  ObservableSet<E> set<E>({
    required final ObservableSet<E> Function(T value) mapper,
    final FactorySet<E>? factory,
  }) {
    return SetSwitchMap<E, T>(
      source: source,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E, S> statefulList<E, S>({
    required final ObservableStatefulList<E, S> Function(T value) mapper,
  }) {
    return StatefulListSwitchMap<E, S, T>(
      source: source,
      mapper: mapper,
    );
  }

  @override
  ObservableStatefulMap<K, V, S> statefulMap<K, V, S>({
    required final ObservableStatefulMap<K, V, S> Function(T value) mapper,
    final FactoryMap<K, V>? factory,
  }) {
    return StatefulMapSwitchMap<K, V, S, T>(
      source: source,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E, S> statefulSet<E, S>({
    required final ObservableStatefulSet<E, S> Function(T value) mapper,
    final FactorySet<E>? factory,
  }) {
    return StatefulSetSwitchMap<E, S, T>(
      source: source,
      mapper: mapper,
      factory: factory,
    );
  }
}
