import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';
import '../../operators/map_item.dart';

class OperatorStatefulListMapItemState<E, E2, S, S2>
    extends StatefulListChangeTransform<E2, S2, Either<List<E>, S>, StatefulListChange<E,S>> {
  final E2 Function(E item) mapper;
  final S2 Function(S state) stateMapper;

  OperatorStatefulListMapItemState({
    required super.source,
    required this.mapper,
    required this.stateMapper,
  });

  @override
  void handleChange(final StatefulListChange<E,S> change) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        ObservableListMapItemOperator.mapChange<E, E2>(
          change,
          applyListUpdateAction,
          mapper,
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableListUpdateAction<E2>, S2>.right(stateMapper(state)));
      },
    );
  }
}
