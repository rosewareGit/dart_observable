import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/map_stateful.dart';
import '../../operators/filter_item.dart';

class OperatorStatefulMapFilterItem<K, V, S> extends OperatorCollectionTransformMapStateful<K, V, S,
    Either<Map<K, V>, S>, Either<ObservableMapChange<K, V>, S>> {
  final bool Function(K key, V value) predicate;

  OperatorStatefulMapFilterItem({
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
          predicate,
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableMapUpdateAction<K, V>, S>.right(state));
      },
    );
  }
}
