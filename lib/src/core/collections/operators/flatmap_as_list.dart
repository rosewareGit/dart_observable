import '../../../../dart_observable.dart';
import '../list/list.dart';
import '../list/list_sync_helper.dart';

class OperatorCollectionsFlatMapAsList<E, E2, C, T extends CollectionState<E, C>> extends RxListImpl<E2> {
  final ObservableCollection<E, C, T> source;
  final ObservableCollectionFlatMapUpdate<E, E2, ObservableList<E2>>? Function(C change) sourceProvider;

  Disposable? _listener;

  final Map<E, ObservableList<E2>> _activeObservables = <E, ObservableList<E2>>{};
  final Map<E, Disposable> _activeObservablesDisposables = <E, Disposable>{};

  final Map<E, ObservableListSyncHelper<E2>> _listSyncHelpersByObservable = <E, ObservableListSyncHelper<E2>>{};

  OperatorCollectionsFlatMapAsList({
    required this.source,
    required this.sourceProvider,
    final List<E2> Function(Iterable<E2>? items)? factory,
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
    final ObservableCollectionFlatMapUpdate<E, E2, ObservableList<E2>>? sourceByValue = sourceProvider(change);
    if (sourceByValue == null) {
      // Change was ignored
      return;
    }

    final Map<E, ObservableList<E2>> registerObservables = sourceByValue.newObservables;
    final Set<E> unregisterObservablesKeys = sourceByValue.removedObservables;

    final Set<int> removeIndexes = <int>{};
    for (final E key in unregisterObservablesKeys) {
      if (_activeObservables.containsKey(key)) {
        final ObservableListSyncHelper<E2>? syncHelper = _listSyncHelpersByObservable[key];
        final ObservableList<E2>? activeObservable = _activeObservables[key];
        if (activeObservable != null) {
          final Iterable<int>? indexesRemoved = syncHelper?.handleRemovedState(activeObservable);
          if (indexesRemoved != null) {
            removeIndexes.addAll(indexesRemoved);
          }
        }
        _activeObservables.remove(key);
        _activeObservablesDisposables[key]?.dispose();
      }
    }

    if (removeIndexes.isNotEmpty) {
      applyAction(
        ObservableListUpdateAction<E2>(removeIndexes: removeIndexes),
      );
    }

    registerObservables.forEach((final E key, final ObservableList<E2> state) {
      final ObservableListSyncHelper<E2> keySyncHelper = _listSyncHelpersByObservable.putIfAbsent(key, () {
        return ObservableListSyncHelper<E2>(
          target: this,
        );
      });
      keySyncHelper.handleInitialState(state: state);

      _activeObservables[key] = state;
      _activeObservablesDisposables[key] = state.listen(
        onChange: (final Observable<ObservableListState<E2>> source) {
          final ObservableListState<E2> value = source.value;
          final ObservableListChange<E2> change = value.lastChange;

          keySyncHelper.handleListChange(
            sourceChange: change,
          );
        },
      );
    });
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
