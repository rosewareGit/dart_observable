import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/map_stateful.dart';

class OperatorStatefulMapChangeFactory<K, V, S> extends OperatorCollectionTransformMapStateful<K, V, S,
    ObservableStatefulMapState<K, V, S>, Either<ObservableMapChange<K, V>, S>> {
  OperatorStatefulMapChangeFactory({
    required super.source,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableMapChange<K, V>, S> change) {
    change.fold(
      onLeft: (final ObservableMapChange<K, V> change) {
        applyAction(
          Either<ObservableMapUpdateAction<K, V>, S>.left(ObservableMapUpdateAction<K, V>.fromChange(change)),
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableMapUpdateAction<K, V>, S>.right(state));
      },
    );
  }
}
