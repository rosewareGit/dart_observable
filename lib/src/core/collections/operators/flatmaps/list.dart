import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../list/list_sync_helper.dart';
import '../../list/rx_impl.dart';
import '../_base_flat_map.dart';

class OperatorCollectionsFlatMapAsList<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS>
    extends RxListImpl<E2>
    with
        BaseCollectionFlatMapOperator<Self, ObservableList<E2>, CS, ObservableListState<E2>, C,
            ObservableListChange<E2>> {
  @override
  final Self source;
  @override
  final ObservableCollectionFlatMapUpdate<ObservableList<E2>>? Function(C change) sourceProvider;

  final Map<ObservableList<E2>, ObservableListSyncHelper<E2>> _listSyncHelpersByObservable =
      <ObservableList<E2>, ObservableListSyncHelper<E2>>{};

  OperatorCollectionsFlatMapAsList({
    required this.source,
    required this.sourceProvider,
    final List<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

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
