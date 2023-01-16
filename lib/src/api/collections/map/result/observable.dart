import '../../../../../dart_observable.dart';

abstract interface class ObservableMapResult<K, V, F>
    implements ObservableCollection<K, ObservableMapResultChange<K, V, F>, ObservableMapResultState<K, V, F>> {
  factory ObservableMapResult.failure(
    final F failure, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return RxMapResult<K, V, F>.failure(failure, factory: factory);
  }

  factory ObservableMapResult.fromCollections({
    required final Iterable<ObservableMapResultUpdater<K, V, F, dynamic>> collections,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapResult<K, V, F>.fromCollections(
      observables: collections,
      factory: factory,
    );
  }

  factory ObservableMapResult.fromStream({
    required final Stream<ObservableMapResultUpdateAction<K, V, F>> stream,
    final F Function(Object error)? onError,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return RxMapResult<K, V, F>.fromStream(
      stream: stream,
      onError: onError,
    );
  }

  factory ObservableMapResult.undefined({
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) {
    return RxMapResult<K, V, F>.undefined(
      factory: factory,
    );
  }

  V? operator [](final K key);

  ObservableMapResult<K, V, F> filterObservableMapAsMapResult(
    final bool Function(K key, V value) predicate, {
    final Map<K, V> Function(Map<K, V>? items)? factory,
  });

  ObservableMapResult<K, V2, F> mapObservableMapAsMapResult<V2>({
    required final V2 Function(V value) valueMapper,
    final Map<K, V2> Function(Map<K, V2>? items)? factory,
  });

  Observable<V?> rxItem(final K key);
}

class ObservableMapResultUpdater<K, V, F, C> {
  final ObservableCollection<dynamic, C, CollectionState<dynamic, C>> source;
  final void Function(C change, Emitter<ObservableMapResultUpdateAction<K, V, F>>) updateFn;

  ObservableMapResultUpdater({
    required this.source,
    required this.updateFn,
  });

  void emitChange(final Emitter<ObservableMapResultUpdateAction<K, V, F>> updater) {
    updateFn(source.value.lastChange, updater);
  }

  void emitInitialChange(final Emitter<ObservableMapResultUpdateAction<K, V, F>> updater) {
    updateFn(source.value.asChange(), updater);
  }

  Disposable listen(final Emitter<ObservableMapResultUpdateAction<K, V, F>> updater) {
    return source.listen(
      onChange: (final Observable<CollectionState<dynamic, C>> source) {
        final C change = source.value.lastChange;
        updateFn(change, updater);
      },
    );
  }
}
