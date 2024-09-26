import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/set_stateful.dart';
import '../../operators/map_item.dart';

class OperatorStatefulSetMapItem<E, E2, S> extends StatefulSetChangeTransform<E2, S,
    ObservableStatefulSetState<E, S>, Either<ObservableSetChange<E>, S>> {
  final E2 Function(E item) mapper;

  OperatorStatefulSetMapItem({
    required super.source,
    required this.mapper,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableSetChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableSetChange<E> change) {
        ObservableSetMapItemOperator.mapChange<E, E2>(
          change,
          applySetUpdateAction,
          mapper,
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableSetUpdateAction<E2>, S>.right(state));
      },
    );
  }
}
