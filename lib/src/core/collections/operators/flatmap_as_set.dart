import '../../../../dart_observable.dart';
import '../set/set.dart';

class OperatorCollectionsFlatMapAsSet<E, E2, C, T extends CollectionState<E, C>> extends RxSetImpl<E2> {
  final ObservableCollection<E, C, T> source;
  final ObservableCollectionFlatMapUpdate<E, E2, ObservableSet<E2>> Function(C change) sourceProvider;

  Disposable? _listener;

  final Map<E, ObservableSet<E2>> _activeObservables = <E, ObservableSet<E2>>{};

  final Map<E, Disposable> _activeObservablesDisposables = <E, Disposable>{};

  OperatorCollectionsFlatMapAsSet({
    required this.source,
    required this.sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  void onInit() {
    super.onInit();
    source.addDisposeWorker(() {
      return Future.wait([
        ..._activeObservablesDisposables.values.map((final Disposable value) async {
          value.dispose();
        }),
        dispose(),
      ]).then((_) {
        _activeObservablesDisposables.clear();
        _activeObservables.clear();
      });
    });
  }

  void _handleChange(final C change) {
    final ObservableCollectionFlatMapUpdate<E, E2, ObservableSet<E2>> sourceByValue = sourceProvider(change);
    final Map<E, ObservableSet<E2>> registerObservables = sourceByValue.newObservables;
    final Set<E> unregisterObservablesKeys = sourceByValue.removedObservables;

    final Set<E2> addItems = <E2>{};
    final Set<E2> removeItems = <E2>{};

    for (final E key in unregisterObservablesKeys) {
      if (_activeObservables.containsKey(key)) {
        removeItems.addAll(_activeObservables[key]!.value.setView);
        _activeObservables.remove(key);
        _activeObservablesDisposables[key]?.dispose();
      }
    }

    registerObservables.forEach((final E key, final ObservableSet<E2> value) {
      addItems.addAll(value.value.setView);
      _activeObservables[key] = value;
      _activeObservablesDisposables[key] = value.listen(
        onChange: (final Observable<ObservableSetState<E2>> source) {
          final ObservableSetState<E2> value = source.value;
          final ObservableSetChange<E2> change = value.lastChange;
          applyAction(
            ObservableSetUpdateAction<E2>(
              addItems: change.added,
              removeItems: change.removed,
            ),
          );
        },
      );
    });

    applyAction(
      ObservableSetUpdateAction<E2>(
        addItems: addItems,
        removeItems: removeItems,
      ),
    );
  }

  void _initListener() {
    if (_listener != null) {
      // TODO buffer
      return;
    }

    final C initial = source.value.asChange();
    _handleChange(initial);

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final T value = source.value;
        final C change = value.lastChange;
        _handleChange(change);
      },
    );
  }
}
