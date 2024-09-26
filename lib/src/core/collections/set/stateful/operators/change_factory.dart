import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/set_stateful.dart';

class OperatorStatefulSetChangeFactory<E, S> extends StatefulSetChangeTransform<E, S,
    ObservableStatefulSetState<E, S>, Either<ObservableSetChange<E>, S>> {
  OperatorStatefulSetChangeFactory({
    required super.source,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableSetChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableSetChange<E> change) {
        applyAction(
          Either<ObservableSetUpdateAction<E>, S>.left(ObservableSetUpdateAction<E>.fromChange(change)),
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableSetUpdateAction<E>, S>.right(state));
      },
    );
  }
}
