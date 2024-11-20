import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';
import '../../operators/map_item.dart';

class OperatorStatefulListMapItem<E, E2, S>
    extends StatefulListChangeTransform<E2, S, ObservableStatefulListState<E, S>, Either<ObservableListChange<E>, S>> {
  final E2 Function(E item) mapper;

  OperatorStatefulListMapItem({
    required super.source,
    required this.mapper,
  });

  @override
  void handleChange(final Either<ObservableListChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        ObservableListMapItemOperator.mapChange<E, E2>(
          change,
          applyListUpdateAction,
          mapper,
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableListUpdateAction<E2>, S>.right(state));
      },
    );
  }
}
