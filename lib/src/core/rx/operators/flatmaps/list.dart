import '../../../../../dart_observable.dart';
import '../../../collections/list/list_sync_helper.dart';
import '../../../collections/list/rx_impl.dart';
import '../_base_flat_map.dart';

class OperatorFlatMapAsList<E2, T, C> extends RxListImpl<E2>
    with BaseFlatMapOperator<ObservableList<E2>, T, C, ObservableListState<E2>> {
  @override
  final Observable<T> source;

  @override
  final ObservableCollectionFlatMapUpdate<ObservableList<E2>>? Function(C change) sourceProvider;
  final C Function(T value, bool initial) toChangeFn;

  final Map<ObservableList<E2>, ObservableListSyncHelper<E2>> _listSyncHelpersByObservable =
      <ObservableList<E2>, ObservableListSyncHelper<E2>>{};

  OperatorFlatMapAsList({
    required this.source,
    required this.toChangeFn,
    required this.sourceProvider,
    super.factory,
  });

  @override
  C fromValue(final T value, final bool initial) => toChangeFn(value, initial);

  @override
  void handleChange(final ObservableList<E2> source) {
    final ObservableListSyncHelper<E2> syncHelper = _listSyncHelpersByObservable.putIfAbsent(source, () {
      return ObservableListSyncHelper<E2>(
        applyAction: applyAction,
      );
    });

    syncHelper.handleListChange(sourceChange: source.value.lastChange);
  }

  @override
  void handleRegisteredObservables(final Set<ObservableList<E2>> registerObservables) {
    for (final ObservableList<E2> observable in registerObservables) {
      final ObservableListSyncHelper<E2> syncHelper = _listSyncHelpersByObservable.putIfAbsent(observable, () {
        return ObservableListSyncHelper<E2>(
          applyAction: applyAction,
        );
      });
      syncHelper.handleInitialState(state: observable);
    }
  }

  @override
  void handleRemovedObservables(final Set<ObservableList<E2>> unregisterObservables) {
    final Set<int> removeIndexes = <int>{};

    for (final ObservableList<E2> observable in unregisterObservables) {
      final ObservableListSyncHelper<E2>? syncHelper = _listSyncHelpersByObservable.remove(observable);
      final Iterable<int>? indexesRemoved = syncHelper?.handleRemovedState(observable);
      if (indexesRemoved != null) {
        removeIndexes.addAll(indexesRemoved);
      }
    }

    if (removeIndexes.isNotEmpty) {
      applyAction(
        ObservableListUpdateAction<E2>(removeIndexes: removeIndexes),
      );
    }
  }
}
