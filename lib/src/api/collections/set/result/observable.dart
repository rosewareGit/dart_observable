import '../../../../../dart_observable.dart';

abstract interface class ObservableSetResult<E, F>
    implements ObservableCollection<E, ObservableSetResultChange<E, F>, ObservableSetResultState<E, F>> {
  factory ObservableSetResult({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return RxSetResult<E, F>(
      initial: initial,
      factory: factory,
    );
  }

  factory ObservableSetResult.failure(
    final F failure, {
    final FactorySet<E>? factory,
  }) {
    return RxSetResult<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }

  factory ObservableSetResult.fromCollections({
    required final Iterable<ObservableSetResultUpdater<E, F, dynamic>> collections,
    final FactorySet<E>? factory,
  }) {
    return RxSetResult<E, F>.fromCollections(
      observables: collections,
      factory: factory,
    );
  }

  factory ObservableSetResult.undefined({
    final FactorySet<E>? factory,
  }) {
    return RxSetResult<E, F>.undefined(factory: factory);
  }

  ObservableSetResult<E, F> filterSetResult(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  });

  Observable<E?> rxItem(final bool Function(E item) predicate);

  Observable<SnapshotResult<E?, F>> rxItemByIndex(final int index);
}

class ObservableSetResultUpdater<E, F, C> {
  final ObservableCollection<dynamic, C, CollectionState<dynamic, C>> source;
  final void Function(C change, Emitter<ObservableSetResultUpdateAction<E, F>>) updateFn;

  ObservableSetResultUpdater({
    required this.source,
    required this.updateFn,
  });

  void emitChange(final Emitter<ObservableSetResultUpdateAction<E, F>> updater) {
    updateFn(source.value.lastChange, updater);
  }

  void emitInitialChange(final Emitter<ObservableSetResultUpdateAction<E, F>> updater) {
    updateFn(source.value.asChange(), updater);
  }

  Disposable listen(final Emitter<ObservableSetResultUpdateAction<E, F>> updater) {
    return source.listen(
      onChange: (final Observable<CollectionState<dynamic, C>> source) {
        final C change = source.value.lastChange;
        updateFn(change, updater);
      },
    );
  }
}
