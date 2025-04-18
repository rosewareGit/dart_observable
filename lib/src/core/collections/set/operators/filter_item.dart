import '../../../../../dart_observable.dart';
import '../../operators/transforms/set.dart';

class ObservableSetFilterOperator<E> extends SetChangeTransform<E, ObservableSetChange<E>, Set<E>> {
  final bool Function(E item) predicate;

  ObservableSetFilterOperator({
    required this.predicate,
    required super.source,
    super.factory,
  });

  @override
  void handleChange(
    final ObservableSetChange<E> change,
  ) {
    filterItems(change, applyAction, predicate);
  }

  static filterItems<E>(
    final ObservableSetChange<E> change,
    final Emitter<ObservableSetUpdateAction<E>> updater,
    final bool Function(E item) predicate,
  ) {
    final Set<E> removed = <E>{
      ...change.removed,
      ...change.added.where((final E item) => predicate(item) == false),
    };
    final Set<E> added = change.added.where(predicate).toSet();

    updater(
      ObservableSetUpdateAction<E>(
        removeItems: removed,
        addItems: added,
      ),
    );
  }
}
