import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';

class ObservableListMapItemOperator<E, E2>
    extends OperatorCollectionTransformAsList<E2, ObservableListChange<E>, ObservableListState<E>> {
  final E2 Function(E item) mapper;

  ObservableListMapItemOperator({
    required this.mapper,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final ObservableListChange<E> change,
    final Emitter<ObservableListUpdateAction<E2>> updater,
  ) {
    mapChange(change, updater, mapper);
  }

  static mapChange<E, E2>(
    final ObservableListChange<E> change,
    final Emitter<ObservableListUpdateAction<E2>> updater,
    final E2 Function(E item) mapper,
  ) {
    final Set<int> removedIndexes = change.removed.keys.toSet();
    final Map<int, E2> updateItems = Map<int, E2>.fromEntries(
      change.updated.entries.map((final MapEntry<int, ObservableItemChange<E>> entry) {
        final int index = entry.key;
        final E item = entry.value.newValue;
        return MapEntry<int, E2>(index, mapper(item));
      }),
    );
    final List<E2> itemsToAdd = change.added.values.map(mapper).toList();

    updater(
      ObservableListUpdateAction<E2>(
        removeIndexes: removedIndexes,
        updateItemAtPosition: updateItems,
        insertItemAtPosition: <MapEntry<int?, Iterable<E2>>>[MapEntry<int?, Iterable<E2>>(null, itemsToAdd)],
      ),
    );
  }
}
