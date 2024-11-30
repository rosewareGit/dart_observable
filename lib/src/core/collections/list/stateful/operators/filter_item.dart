import '../../../../../../dart_observable.dart';
import '../../../operators/transforms/list_stateful.dart';
import '../../list_sync_helper.dart';

class StatefulListFilterOperator<E, S>
    extends StatefulListChangeTransform<E, S, Either<List<E>, S>, StatefulListChange<E, S>> {
  final bool Function(E item) predicate;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: predicate,
    actionHandler: this,
  );

  StatefulListFilterOperator({
    required super.source,
    required this.predicate,
  });

  @override
  void handleChange(final StatefulListChange<E, S> change) {
    change.fold(
      onLeft: (final ObservableListChange<E> change) {
        _helper.handleListSync(sourceChange: change);
      },
      onRight: (final S state) {
        applyAction(StatefulListAction<E, S>.right(state));
      },
    );
  }
}
