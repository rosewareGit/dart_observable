import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/set_stateful.dart';
import '../../operators/map_item.dart';

class OperatorStatefulSetMapItemWithState<E, E2, S, S2>
    extends StatefulSetChangeTransform<E2, S2, ObservableStatefulSetState<E, S>, Either<ObservableSetChange<E>, S>> {
  final E2 Function(E item) mapper;
  final S2 Function(S state) stateMapper;

  OperatorStatefulSetMapItemWithState({
    required super.source,
    required this.mapper,
    required this.stateMapper,
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
        applyAction(Either<ObservableSetUpdateAction<E2>, S2>.right(stateMapper(state)));
      },
    );
  }
}
