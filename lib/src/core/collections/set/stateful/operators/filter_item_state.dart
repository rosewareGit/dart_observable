import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/set_stateful.dart';
import '../../operators/filter_item.dart';

class OperatorStatefulSetFilterItemState<E, S>
    extends StatefulSetChangeTransform<E, S, ObservableStatefulSetState<E, S>, Either<ObservableSetChange<E>, S>> {
  final bool Function(Either<E, S> change) predicate;

  OperatorStatefulSetFilterItemState({
    required super.source,
    required this.predicate,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableSetChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableSetChange<E> change) {
        ObservableSetFilterOperator.filterItems(
          change,
          applySetUpdateAction,
          (final E item) => predicate(
            Either<E, S>.left(item),
          ),
        );
      },
      onRight: (final S state) {
        if (predicate(Either<E, S>.right(state))) {
          applyAction(Either<ObservableSetUpdateAction<E>, S>.right(state));
        }
      },
    );
  }
}
