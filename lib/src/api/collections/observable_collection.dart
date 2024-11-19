import '../../../dart_observable.dart';
import 'collection_transforms.dart';

export 'item_change.dart';
export 'map/change.dart';
export 'map/observable_map.dart';
export 'map/rx_map.dart';
export 'map/state.dart';

abstract interface class ObservableCollection<T, C> implements Observable<T> {
  ObservableCollectionSwitchMaps<C> get switchMapChangeAs;

  ObservableCollectionTransforms<C> get transformChangeAs;

  C get change;

  C get currentStateAsChange;

  Disposable onChange({
    required final void Function(C change) onChange,
  });
}

// T: The type of the collection state
// S: The type of the other state
abstract class ObservableCollectionState<T, S> {
  final Either<T, S> _state;

  ObservableCollectionState(final Either<T, S> state) : _state = state;

  bool get isCustom => _state.isLeft;

  bool get isData => _state.isRight;

  T? get leftOrNull => _state.leftOrNull;

  T get leftOrThrow => _state.leftOrThrow;

  S? get rightOrNull => _state.rightOrNull;

  S get rightOrThrow => _state.rightOrThrow;

  R fold<R>({
    required final R Function(T state) onData,
    required final R Function(S state) onCustom,
  }) {
    return _state.fold(
      onLeft: onData,
      onRight: onCustom,
    );
  }

  void when({
    final void Function(T state)? onData,
    final void Function(S state)? onCustom,
  }) {
    _state.when(
      onLeft: onData,
      onRight: onCustom,
    );
  }
}

abstract interface class ObservableCollectionStateful<
    C, // The collection change type
    S, //  The other state type
    T // The collection state type
    > implements ObservableCollection<T, Either<C, S>> {}

class ObservableCollectionSwitchMapUpdate<O extends Observable<dynamic>> {
  final Set<O> newObservables;
  final Set<O> removedObservables;

  ObservableCollectionSwitchMapUpdate({
    required this.newObservables,
    required this.removedObservables,
  });
}
