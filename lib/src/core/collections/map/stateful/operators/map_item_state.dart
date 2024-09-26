import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/map_stateful.dart';
import '../../operators/map_item.dart';

class OperatorStatefulMapMapItemWithState<K, V, V2, S, S2> extends OperatorCollectionTransformMapStateful<K, V2, S2,
    ObservableStatefulMapState<K, V, S>, Either<ObservableMapChange<K, V>, S>> {
  final V2 Function(K key, V value) mapper;
  final S2 Function(S state) stateMapper;

  OperatorStatefulMapMapItemWithState({
    required super.source,
    required this.mapper,
    required this.stateMapper,
    required super.factory,
  });

  @override
  void handleChange(final Either<ObservableMapChange<K, V>, S> change) {
    change.fold(
      onLeft: (final ObservableMapChange<K, V> change) {
        OperatorMapMap.mapChange<K, V, V2>(
          change,
          applyMapUpdateAction,
          mapper,
        );
      },
      onRight: (final S state) {
        applyAction(Either<ObservableMapUpdateAction<K, V2>, S2>.right(stateMapper(state)));
      },
    );
  }
}
