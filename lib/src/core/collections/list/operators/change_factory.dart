import '../../../../../dart_observable.dart';
import '../../operators/transforms/list.dart';
import '../list_sync_helper.dart';

class ObservableListFactoryOperator<E>
    extends OperatorTransformAsList<ObservableList<E>, E, ObservableListChange<E>, ObservableListState<E>> {
  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    applyAction: applyAction,
  );

  ObservableListFactoryOperator({
    required super.factory,
    required super.source,
  });

  @override
  void transformChange(
    final ObservableListChange<E> change,
    final Emitter<ObservableListUpdateAction<E>> updater,
  ) {
    _helper.handleListChange(sourceChange: change);
  }
}
