import '../../../../dart_observable.dart';
import 'transforms/maps.dart';
import 'transforms/sets.dart';

abstract interface class ObservableCollectionTransforms<C> {
  OperatorsTransformLists<C> get lists;

  OperatorsTransformMaps<C> get maps;

  OperatorsTransformSets<C> get sets;

  ObservableList<E2> list<E2>({
    required final void Function(
      ObservableList<E2> state,
      C change,
      Emitter<ObservableListUpdateAction<E2>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  });

  ObservableMap<K, V> map<K, V>({
    required final MapUpdater<K, V, C> transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E2> set<E2>({
    required final void Function(
      ObservableSet<E2> state,
      C change,
      Emitter<ObservableSetUpdateAction<E2>> updater,
    ) transform,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  });
}
