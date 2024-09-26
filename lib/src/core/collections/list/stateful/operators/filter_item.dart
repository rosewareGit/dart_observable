import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';
import '../../list_sync_helper.dart';

class StatefulListFilterOperator<E, S> extends StatefulListChangeTransform<E, S,
    ObservableStatefulListState<E, S>, Either<ObservableListChange<E>, S>> {
  final bool Function(E item) predicate;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: predicate,
    applyAction: applyListUpdateAction,
  );

  StatefulListFilterOperator({
    required super.source,
    required this.predicate,
    super.factory,
  });

  @override
  void handleChange(final Either<ObservableListChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        _helper.handleListChange(sourceChange: change);
      },
      onRight: (final S state) {
        _helper.reset();
        applyAction(Either<ObservableListUpdateAction<E>, S>.right(state));
      },
    );
  }
}
