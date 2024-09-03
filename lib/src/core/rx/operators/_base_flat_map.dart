import '../../../../dart_observable.dart';

mixin BaseFlatMapOperator<
    Current extends Observable<T2>,
    T, // Collection state for this
    C, // The change to handle
    T2 // Collection state for the transformed
    > on RxBase<T2> {
  Disposable? _listener;
  final Set<Current> _activeObservables = <Current>{};
  final Map<Current, Disposable> _activeObservablesDisposables = <Current, Disposable>{};

  late final List<T> _bufferedChanges = <T>[];

  Observable<T> get source;

  C fromValue(final T value, final bool initial);

  ObservableCollectionFlatMapUpdate<Current>? Function(C value) get sourceProvider;

  void handleChange(final Current source);

  void handleRegisteredObservables(final Set<Current> registerObservables);

  void handleRemovedObservables(final Set<Current> unregisterObservables);

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() {
      return Future.wait(<Future<void>>[
        ..._activeObservablesDisposables.values.map((final Disposable value) async {
          value.dispose();
        }),
        dispose(),
      ]).then((final _) {
        _activeObservablesDisposables.clear();
        _activeObservables.clear();
      });
    });
  }

  void _handleValue(final T value, final bool initial) {
    final ObservableCollectionFlatMapUpdate<Current>? sourceByValue = sourceProvider(fromValue(value, initial));
    if (sourceByValue == null) {
      // Change was ignored
      return;
    }

    final Set<Current> registerObservables = sourceByValue.newObservables;
    final Set<Current> unregisterObservables = sourceByValue.removedObservables;

    for (final Current observableToRemove in unregisterObservables) {
      if (_activeObservables.contains(observableToRemove)) {
        _activeObservables.remove(observableToRemove);
        _activeObservablesDisposables[observableToRemove]?.dispose();
      }
    }

    handleRemovedObservables(unregisterObservables);
    handleRegisteredObservables(registerObservables);
    for (final Current state in registerObservables) {
      _activeObservables.add(state);
      _activeObservablesDisposables[state] = state.listen(
        onChange: (final T2 value) {
          handleChange(state);
        },
      );
    }
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final T change in _bufferedChanges) {
        _handleValue(change, false);
      }
      _bufferedChanges.clear();
      return;
    }

    final T value = source.value;
    _handleValue(value, true);

    _listener = source.listen(
      onChange: (final T value) {
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _bufferedChanges.add(value);
          return;
        }
        _handleValue(value, false);
      },
    );
  }
}
