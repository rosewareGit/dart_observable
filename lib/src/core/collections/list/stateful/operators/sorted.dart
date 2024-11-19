import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';
import '../../list_sync_helper.dart';

class ObservableStatefulListSortedOperator<E, S>
    extends StatefulListChangeTransform<E, S, ObservableStatefulListState<E, S>, Either<ObservableListChange<E>, S>> {
  final Comparator<E> comparator;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    actionHandler: this,
    comparator: comparator,
  );

  ObservableStatefulListSortedOperator({
    required this.comparator,
    required super.source,
  });

  @override
  void handleChange(final Either<ObservableListChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        _helper.handleListSync(sourceChange: change);
      },
      onRight: (final S state) {
        applyAction(Either<ObservableListUpdateAction<E>, S>.right(state));
      },
    );
  }
}
