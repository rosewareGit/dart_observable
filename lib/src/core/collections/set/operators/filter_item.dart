import '../../../../../dart_observable.dart';
import '../../operators/transforms/set.dart';

class ObservableSetFilterOperator<E>
    extends OperatorCollectionTransformAsSet<E, ObservableSetChange<E>, ObservableSetState<E>> {
  final bool Function(E item) predicate;

  ObservableSetFilterOperator({
    required this.predicate,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final ObservableSetChange<E> change,
    final Emitter<ObservableSetUpdateAction<E>> updater,
  ) {
    filterItems(change, updater, predicate);
  }

  static filterItems<E>(
    final ObservableSetChange<E> change,
    final Emitter<ObservableSetUpdateAction<E>> updater,
    final bool Function(E item) predicate,
  ) {
    final Set<E> removed = change.removed;
    final Set<E> added = change.added.where(predicate).toSet();

    updater(
      ObservableSetUpdateAction<E>(
        removeItems: removed,
        addItems: added,
      ),
    );
  }
}
