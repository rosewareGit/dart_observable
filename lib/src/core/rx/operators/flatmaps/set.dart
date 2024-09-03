import '../../../../../dart_observable.dart';
import '../../../collections/set/rx_impl.dart';
import '../_base_flat_map.dart';

class OperatorFlatMapAsSet<E, T, C> extends RxSetImpl<E>
    with BaseFlatMapOperator<ObservableSet<E>, T, C, ObservableSetState<E>> {
  @override
  final Observable<T> source;
  @override
  final ObservableCollectionFlatMapUpdate<ObservableSet<E>> Function(C change) sourceProvider;
  final C Function(T value, bool initial) toChangeFn;

  OperatorFlatMapAsSet({
    required this.source,
    required this.sourceProvider,
    required this.toChangeFn,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) : super(factory: factory);

  @override
  C fromValue(final T value, final bool initial) => toChangeFn(value, initial);

  @override
  void handleChange(final ObservableSet<E> source) {
    final ObservableSetState<E> value = source.value;
    final ObservableSetChange<E> change = value.lastChange;
    applyAction(
      ObservableSetUpdateAction<E>(
        addItems: change.added,
        removeItems: change.removed,
      ),
    );
  }

  @override
  void handleRegisteredObservables(final Set<ObservableSet<E>> registerObservables) {
    final Set<E> addItems = <E>{};

    for (final ObservableSet<E> observable in registerObservables) {
      final ObservableSetState<E> state = observable.value;
      addItems.addAll(state.setView);
    }

    applyAction(
      ObservableSetUpdateAction<E>(
        addItems: addItems,
        removeItems: <E>{},
      ),
    );
  }

  @override
  void handleRemovedObservables(final Set<ObservableSet<E>> unregisterObservables) {
    final Set<E> removeItems = <E>{};

    for (final ObservableSet<E> observable in unregisterObservables) {
      final ObservableSetState<E> state = observable.value;
      removeItems.addAll(state.setView);
    }

    applyAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{},
        removeItems: removeItems,
      ),
    );
  }
}
