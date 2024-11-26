import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/map_stateful.dart';

class OperatorStatefulMapChangeFactory<K, V, S> extends OperatorCollectionTransformMapStateful<K, V, S,
    Either<Map<K, V>, S>, Either<ObservableMapChange<K, V>, S>> {
  OperatorStatefulMapChangeFactory({
    required super.source,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableMapChange<K, V>, S> change) {
    change.fold(
      onLeft: (final ObservableMapChange<K, V> change) {
        final Set<K> removeKeys = change.removed.keys.toSet();
        final Map<K, V> addItems = <K, V>{
          ...change.added,
          ...change.updated.map(
            (final K key, final ObservableItemChange<V> change) => MapEntry<K, V>(key, change.newValue),
          ),
        };

        if (removeKeys.isNotEmpty || addItems.isNotEmpty) {
          applyAction(
            Either<ObservableMapUpdateAction<K, V>, S>.left(
              ObservableMapUpdateAction<K, V>(
                removeKeys: removeKeys,
                addItems: addItems,
              ),
            ),
          );
        }
      },
      onRight: (final S state) {
        applyAction(Either<ObservableMapUpdateAction<K, V>, S>.right(state));
      },
    );
  }
}
