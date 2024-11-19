import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/map_stateful.dart';
import '../../operators/filter_item.dart';

class OperatorStatefulMapFilterItemWithState<K, V, S> extends OperatorCollectionTransformMapStateful<K, V, S,
    ObservableStatefulMapState<K, V, S>, Either<ObservableMapChange<K, V>, S>> {
  final bool Function(Either<MapEntry<K, V>, S>) predicate;

  OperatorStatefulMapFilterItemWithState({
    required super.source,
    required this.predicate,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableMapChange<K, V>, S> change) {
    change.fold(
      onLeft: (final ObservableMapChange<K, V> change) {
        OperatorMapFilter.filterChange<K, V>(
          change,
          applyMapUpdateAction,
          (final K key, final V value) {
            return predicate(Either<MapEntry<K, V>, S>.left(MapEntry<K, V>(key, value)));
          },
        );
      },
      onRight: (final S state) {
        final bool shouldApply = predicate(Either<MapEntry<K, V>, S>.right(state));
        if (shouldApply) {
          applyAction(Either<ObservableMapUpdateAction<K, V>, S>.right(state));
        }
      },
    );
  }
}
