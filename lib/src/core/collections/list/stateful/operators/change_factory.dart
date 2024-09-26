import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';

class OperatorStatefulListChangeFactory<E, S> extends StatefulListChangeTransform<E, S,
    ObservableStatefulListState<E, S>, Either<ObservableListChange<E>, S>> {
  OperatorStatefulListChangeFactory({
    required super.source,
    required final FactoryList<E> factory,
  }) : super(factory: factory);

  @override
  void handleChange(
    final Either<ObservableListChange<E>, S> change,
  ) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        applyAction(
          Either<ObservableListUpdateAction<E>, S>.left(ObservableListUpdateAction<E>.fromChange(change)),
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableListUpdateAction<E>, S>.right(state));
      },
    );
  }
}
