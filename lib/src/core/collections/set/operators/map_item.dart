import '../../../../../dart_observable.dart';
import '../../operators/transforms/set.dart';

class ObservableSetMapItemOperator<E, E2> extends SetChangeTransform<E2, ObservableSetChange<E>, Set<E>> {
  final E2 Function(E item) mapper;

  ObservableSetMapItemOperator({
    required this.mapper,
    required super.source,
    super.factory,
  });

  @override
  void handleChange(
    final ObservableSetChange<E> change,
  ) {
    mapChange(change, applyAction, mapper);
  }

  static void mapChange<E, E2>(
    final ObservableSetChange<E> change,
    final Emitter<ObservableSetUpdateAction<E2>> updater,
    final E2 Function(E item) mapper,
  ) {
    final Set<E2> removedIndexes = change.removed.map(mapper).toSet();
    final Set<E2> updateItems = change.added.map(mapper).toSet();

    updater(
      ObservableSetUpdateAction<E2>(
        addItems: updateItems,
        removeItems: removedIndexes,
      ),
    );
  }
}
