import '../../../../../dart_observable.dart';
import '../../operators/transform_as_list.dart';
import '../list_sync_helper.dart';

class ObservableListFilterOperator<E>
    extends OperatorCollectionsTransformAsList<E, E, ObservableListChange<E>, ObservableListState<E>> {
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
