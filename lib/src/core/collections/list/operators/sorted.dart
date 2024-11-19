import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';
import '../list_sync_helper.dart';

class ObservableListSortedOperator<E> extends ListChangeTransform<E, ObservableListChange<E>, ObservableListState<E>> {
  final Comparator<E> comparator;

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    actionHandler: this,
    comparator: comparator,
  );

  ObservableListSortedOperator({
    required this.comparator,
    required super.source,
  });

  @override
  void handleChange(final ObservableListChange<E> change) {
    _helper.handleListSync(sourceChange: change);
  }
}
