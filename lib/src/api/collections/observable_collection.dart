import '../../../dart_observable.dart';

export 'item_change.dart';
export 'map/change.dart';
export 'map/observable.dart';
export 'map/rx.dart';
export 'map/state.dart';

abstract interface class ObservableCollection<C, CS extends CollectionState<C>> implements Observable<CS> {
  ObservableTransforms<C> get transformChangeAs;

  ObservableFlatMaps<C> get flatMapChangeAs;
}

class ObservableCollectionFlatMapUpdate<O extends Observable<dynamic>> {
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
    CS extends CollectionState<StateOf<C, S>> // The collection state type
    > implements ObservableCollection<StateOf<C, S>, CS> {}
