import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';
import '../list_sync_helper.dart';

class ObservableListFilterOperator<E>
    extends OperatorCollectionTransformAsList<E, ObservableListChange<E>, ObservableListState<E>> {
  final bool Function(E item) predicate;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: predicate,
    applyAction: applyAction,
  );

  ObservableListFilterOperator({
    required this.predicate,
    required super.source,
    super.factory,
  });

  @override
  void transformChange(
    final ObservableListChange<E> change,
    final Emitter<ObservableListUpdateAction<E>> updater,
  ) {
    _helper.handleListChange(sourceChange: change);
  }
}
