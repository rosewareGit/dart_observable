import '../../../dart_observable.dart';
import 'collection_transforms.dart';

export 'item_change.dart';
export 'map/change.dart';
export 'map/observable.dart';
export 'map/rx.dart';
export 'map/state.dart';

abstract interface class ObservableCollection<C, CS extends CollectionState<C>> implements Observable<CS> {
  ObservableCollectionSwitchMaps<C> get switchMapChangeAs;

  ObservableCollectionTransforms<C> get transformChangeAs;
}

abstract class ObservableCollectionState<CS extends CollectionState<C>, C, S> extends CollectionState<Either<C, S>> {
  final Either<CS, S> _state;

  ObservableCollectionState.custom(final S custom) : _state = Either<CS, S>.right(custom);

  ObservableCollectionState.data(final CS state) : _state = Either<CS, S>.left(state);

  bool get isCustom => _state.isLeft;

  bool get isData => _state.isRight;

  @override
  Either<C, S> get lastChange {
    return _state.fold(
      onLeft: (final CS state) => Either<C, S>.left(state.lastChange),
      onRight: (final S state) => Either<C, S>.right(state),
    );
  }

  CS? get leftOrNull => _state.leftOrNull;

  CS get leftOrThrow => _state.leftOrThrow;

  S? get rightOrNull => _state.rightOrNull;

  S get rightOrThrow => _state.rightOrThrow;

  @override
  Either<C, S> asChange() {
    return _state.fold(
      onLeft: (final CS state) => Either<C, S>.left(state.asChange()),
      onRight: (final S state) => Either<C, S>.right(state),
    );
  }

  R fold<R>({
    required final R Function(CS state) onData,
    required final R Function(S state) onCustom,
  }) {
    return _state.fold(
      onLeft: onData,
      onRight: onCustom,
    );
  }

  void when({
    final void Function(CS state)? onData,
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
    CS extends CollectionState<Either<C, S>> // The collection state type
    > implements ObservableCollection<Either<C, S>, CS> {}

class ObservableCollectionSwitchMapUpdate<O extends Observable<dynamic>> {
  final Set<O> newObservables;
  final Set<O> removedObservables;

  ObservableCollectionSwitchMapUpdate({
    required this.newObservables,
    required this.removedObservables,
  });
}
