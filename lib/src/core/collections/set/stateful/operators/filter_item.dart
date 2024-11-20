import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/set_stateful.dart';
import '../../operators/filter_item.dart';

class OperatorStatefulSetFilterItem<E, S>
    extends StatefulSetChangeTransform<E, S, ObservableStatefulSetState<E, S>, Either<ObservableSetChange<E>, S>> {
  final bool Function(E item) predicate;

  OperatorStatefulSetFilterItem({
    required super.source,
    required this.predicate,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableSetChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableSetChange<E> change) {
        ObservableSetFilterOperator.filterItems(change, applySetUpdateAction, predicate);
      },
      onRight: (final S state) {
        applyAction(Either<ObservableSetUpdateAction<E>, S>.right(state));
      },
    );
  }
}
