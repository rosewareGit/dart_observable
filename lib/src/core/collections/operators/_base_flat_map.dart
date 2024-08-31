import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../../rx/base_tracking.dart';

mixin BaseCollectionFlatMapOperator<
    Self extends ChangeTrackingObservable<Self, CS, C>,
    Current extends ChangeTrackingObservable<Current, CS2, C2>,
    CS, // Collection state for this
    CS2, // Collection state for the transformed
    C,
    C2> on RxBaseTracking<Current, CS2, C2> {
  Disposable? _listener;
  final Set<Current> _activeObservables = <Current>{};
  final Map<Current, Disposable> _activeObservablesDisposables = <Current, Disposable>{};

  late final List<C> _bufferedChanges = <C>[];

  Self get source;

  ObservableCollectionFlatMapUpdate<Current>? Function(C change) get sourceProvider;

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

  void _handleChange(final C change) {
    final ObservableCollectionFlatMapUpdate<Current>? sourceByValue = sourceProvider(change);
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
        onChange: (final Current source) {
          handleChange(source);
        },
      );
    }
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final C change in _bufferedChanges) {
        _handleChange(change);
      }
      _bufferedChanges.clear();
      return;
    }

    final C initial = source.asChange(source.value);
    _handleChange(initial);

    _listener = source.listen(
      onChange: (final Self source) {
        final CS value = source.value;
        final C change = source.lastChange(value);
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _bufferedChanges.add(change);
          return;
        }
        _handleChange(change);
      },
    );
  }
}
