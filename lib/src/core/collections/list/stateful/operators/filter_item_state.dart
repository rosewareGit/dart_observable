import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';
import '../../list_sync_helper.dart';

class OperatorStatefulListFilterItemState<E, S>
    extends StatefulListChangeTransform<E, S, ObservableStatefulListState<E, S>, Either<ObservableListChange<E>, S>> {
  final bool Function(Either<E, S> item) predicate;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: (final E item) {
      return predicate(Either<E, S>.left(item));
    },
    actionHandler: this,
  );

  OperatorStatefulListFilterItemState({
    required super.source,
    required this.predicate,
  });

  @override
  void handleChange(final Either<ObservableListChange<E>, S> change) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        _helper.handleListSync(sourceChange: change);
      },
      onRight: (final S state) {
        if (predicate(Either<E, S>.right(state))) {
          applyAction(Either<ObservableListUpdateAction<E>, S>.right(state));
        }
      },
    );
  }
}
