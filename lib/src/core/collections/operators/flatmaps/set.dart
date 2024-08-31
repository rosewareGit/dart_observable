import '../../../../../dart_observable.dart';
import '../../../../api/change_tracking_observable.dart';
import '../../set/rx_impl.dart';
import '../_base_flat_map.dart';

class OperatorCollectionsFlatMapAsSet<Self extends ChangeTrackingObservable<Self, CS, C>, E2, C, CS>
    extends RxSetImpl<E2>
    with
        BaseCollectionFlatMapOperator<Self, ObservableSet<E2>, CS, ObservableSetState<E2>, C, ObservableSetChange<E2>> {
  @override
  final Self source;
  @override
  final ObservableCollectionFlatMapUpdate<ObservableSet<E2>> Function(C change) sourceProvider;

  OperatorCollectionsFlatMapAsSet({
    required this.source,
    required this.sourceProvider,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

  @override
  void handleChange(final ObservableSet<E2> source) {
    final ObservableSetState<E2> value = source.value;
    final ObservableSetChange<E2> change = value.lastChange;
    applyAction(
      ObservableSetUpdateAction<E2>(
        addItems: change.added,
        removeItems: change.removed,
      ),
    );
  }

  @override
  void handleRegisteredObservables(final Set<ObservableSet<E2>> registerObservables) {
    final Set<E2> addItems = <E2>{};

    for (final ObservableSet<E2> observable in registerObservables) {
      final ObservableSetState<E2> state = observable.value;
      addItems.addAll(state.setView);
    }

    applyAction(
      ObservableSetUpdateAction<E2>(
        addItems: addItems,
        removeItems: <E2>{},
      ),
    );
  }

  @override
  void handleRemovedObservables(final Set<ObservableSet<E2>> unregisterObservables) {
    final Set<E2> removeItems = <E2>{};

    for (final ObservableSet<E2> observable in unregisterObservables) {
      final ObservableSetState<E2> state = observable.value;
      removeItems.addAll(state.setView);
    }

    applyAction(
      ObservableSetUpdateAction<E2>(
        addItems: <E2>{},
        removeItems: removeItems,
      ),
    );
  }
}
