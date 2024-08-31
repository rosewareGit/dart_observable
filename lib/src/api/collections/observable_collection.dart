import '../../../dart_observable.dart';
import '../change_tracking_observable.dart';

export 'item_change.dart';
export 'map/change.dart';
export 'map/observable.dart';
export 'map/rx.dart';
export 'map/state.dart';

abstract interface class ObservableCollection<
    Self extends ObservableCollection<Self, C, CS>, // Self type
    C,
    CS extends ChangeTrackingState<C>> implements ChangeTrackingObservable<Self, CS, C> {}

class ObservableCollectionFlatMapUpdate<O extends ChangeTrackingObservable<dynamic, dynamic, dynamic>> {
  final Set<O> newObservables;
  final Set<O> removedObservables;

  ObservableCollectionFlatMapUpdate({
    required this.newObservables,
    required this.removedObservables,
  });
}

abstract interface class ObservableCollectionStateful<
    Self extends ObservableCollectionStateful<Self, C, S, CS>, // Self type
    C, // The collection change type
    S, //  The other state type
    CS extends ChangeTrackingState<StateOf<C, S>> // The collection state type
    > implements ObservableCollection<Self, StateOf<C, S>, CS> {}
