import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';
import '../list_sync_helper.dart';

class ObservableListFilterOperator<E> extends ListChangeTransform<E, ObservableListChange<E>, ObservableListState<E>> {
  final bool Function(E item) predicate;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: predicate,
    actionHandler: this,
  );

  ObservableListFilterOperator({
    required this.predicate,
    required super.source,
  });

  @override
  void handleChange(final ObservableListChange<E> change) {
    _helper.handleListSync(sourceChange: change);
  }
}
