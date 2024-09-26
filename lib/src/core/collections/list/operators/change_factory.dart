import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';
import '../list_sync_helper.dart';

class ObservableListFactoryOperator<E>
    extends ListChangeTransform<E, ObservableListChange<E>, ObservableListState<E>> {
  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    applyAction: applyAction,
  );

  ObservableListFactoryOperator({
    required super.factory,
    required super.source,
  });

  @override
  void handleChange(final ObservableListChange<E> change) {
    _helper.handleListChange(sourceChange: change);
  }
}
