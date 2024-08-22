import '../../../../../dart_observable.dart';
import '../../list/list_sync_helper.dart';
import '../transforms/list.dart';

class ObservableListFilterOperator<E>
    extends OperatorTransformAsList<ObservableList<E>, E, ObservableListChange<E>, ObservableListState<E>> {
  final bool Function(E item) predicate;

  ObservableListFilterOperator({
    required this.predicate,
    required super.source,
    super.factory,
  });

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: predicate,
    target: this,
  );

  @override
  void transformChange(
    final ObservableList<E> state,
    final ObservableListChange<E> change,
    final Emitter<ObservableListUpdateAction<E>> updater,
  ) {
    _helper.handleListChange(sourceChange: change);
  }
}
