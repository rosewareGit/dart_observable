import '../../../dart_observable.dart';
import '../change_tracking_observable.dart';

export 'item_change.dart';
export 'map/change.dart';
export 'map/observable.dart';
export 'map/rx.dart';
export 'map/state.dart';

typedef MapTransformUpdater<K, V, K2, V2, C> = void Function(
  ObservableMap<K2, V2> state,
  C change,
  Emitter<ObservableMapUpdateAction<K2, V2>> updater,
);

typedef MapUpdater<K, V, C> = void Function(
  ObservableMap<K, V> state,
  C change,
  Emitter<ObservableMapUpdateAction<K, V>> updater,
);

abstract interface class ObservableCollection<
    Self extends ObservableCollection<Self, E, C, CS>, // Self type
    E, //
    C,
    CS extends ChangeTrackingState<C>> implements ChangeTrackingObservable<Self, CS, C> {}

class ObservableCollectionFlatMapUpdate<E1, E2, O extends ObservableCollection<dynamic, E2, dynamic, dynamic>> {
  final Map<E1, O> newObservables;
  final Set<E1> removedObservables;

  ObservableCollectionFlatMapUpdate({required this.newObservables, required this.removedObservables});
}

abstract interface class ObservableCollectionStateful<
    Self extends ObservableCollectionStateful<Self, E, C, S, CS>, // Self type
    E, // Item type
    C, // The collection change type
    S, //  The other state type
    CS extends ChangeTrackingState<StateOf<C, S>> // The collection state type
    > implements ObservableCollection<Self, E, StateOf<C, S>, CS> {}
