import '../../../dart_observable.dart';

export 'item_change.dart';
export 'map/change.dart';
export 'map/observable.dart';
export 'map/result/observable.dart';
export 'map/result/rx.dart';
export 'map/result/state.dart';
export 'map/rx.dart';
export 'map/state.dart';

abstract interface class ObservableCollection<E, C, T extends CollectionState<E, C>> implements Observable<T> {
  ObservableMap<K, V> flatMapCollectionAsMap<K, V>({
    required final ObservableCollectionFlatMapUpdate<E, K, ObservableMap<K, V>> Function(C change) sourceProvider,
    final FactoryMap<K, V>? factory,
  });

  ObservableSet<E2> flatMapCollectionAsSet<E2>({
    required final ObservableCollectionFlatMapUpdate<E, E2, ObservableSet<E2>> Function(C change) sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  });

  ObservableList<E2> transformCollectionAsList<E2>({
    required final void Function(
      ObservableList<E2> state,
      C change,
      Emitter<ObservableListUpdateAction<E2>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  });

  ObservableListResult<E2, F> transformCollectionAsListResult<E2, F>({
    required final void Function(
      ObservableListResult<E2, F> state,
      C change,
      Emitter<ObservableListResultUpdateAction<E2, F>> updater,
    ) transform,
    final FactoryList<E2>? factory,
  });

  ObservableMap<K, V> transformCollectionAsMap<K, V>({
    required final void Function(
      ObservableMap<K, V> state,
      C change,
      Emitter<ObservableMapUpdateAction<K, V>> updater,
    ) transform,
    final FactoryMap<K, V>? factory,
  });

  ObservableMapResult<K2, V2, F> transformCollectionAsMapResult<K2, V2, F>({
    required final void Function(
      ObservableMapResult<K2, V2, F> state,
      C change,
      Emitter<ObservableMapResultUpdateAction<K2, V2, F>> updater,
    ) transform,
    final FactoryMap<K2, V2>? factory,
  });

  ObservableSet<E2> transformCollectionAsSet<E2>({
    required final void Function(
      ObservableSet<E2> state,
      C change,
      Emitter<ObservableSetUpdateAction<E2>> updater,
    ) transform,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  });

  ObservableSetResult<E2, F> transformCollectionAsSetResult<E2, F>({
    required final void Function(
      ObservableSetResult<E2, F> state,
      C change,
      Emitter<ObservableSetResultUpdateAction<E2, F>> updater,
    ) transform,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  });
}

class ObservableCollectionFlatMapUpdate<E1, E2, O extends ObservableCollection<E2, dynamic, dynamic>> {
  final Map<E1, O> newObservables;
  final Set<E1> removedObservables;

  ObservableCollectionFlatMapUpdate({required this.newObservables, required this.removedObservables});
}
