import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';

class ObservableListMapItemOperator<E, E2> extends ListChangeTransform<E2, List<E>, ObservableListChange<E>> {
  final E2 Function(E item) mapper;

  ObservableListMapItemOperator({
    required this.mapper,
    required super.source,
  });

  @override
  void handleChange(
    final ObservableListChange<E> change,
  ) {
    mapChange(change, applyAction, mapper);
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

    if (removedIndexes.isEmpty && updateItems.isEmpty && itemsToAdd.isEmpty) {
      return;
    }

    updater(
      ObservableListUpdateAction<E2>(
        removeAtPositions: removedIndexes,
        updateItems: updateItems,
        addItems: itemsToAdd,
      ),
    );
  }
}
