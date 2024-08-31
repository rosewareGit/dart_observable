import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';
import '../../list_sync_helper.dart';

class OperatorStatefulListFilterItem<Self extends RxListStateful<O, E, S>, O extends ObservableListStateful<O, E, S>, E,
    S> {
  final O source;
  final Self result;
  final bool Function(E item) predicate;

  late final BaseCollectionTransformOperatorProxy<O, ObservableListStatefulState<E, S>,
          ObservableListStatefulState<E, S>, StateOf<ObservableListChange<E>, S>, StateOf<ObservableListChange<E>, S>>
      proxy = BaseCollectionTransformOperatorProxy<O, ObservableListStatefulState<E, S>,
          ObservableListStatefulState<E, S>, StateOf<ObservableListChange<E>, S>, StateOf<ObservableListChange<E>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  late final ObservableListSyncHelper<E> _helper = ObservableListSyncHelper<E>(
    predicate: predicate,
    applyAction: (final ObservableListUpdateAction<E> listAction) {
      return result.applyListUpdateAction(listAction);
    },
  );

  OperatorStatefulListFilterItem({
    required this.source,
    required this.predicate,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableListChange<E>, S> change) {
    change.fold(
      onData: (final ObservableListChange<E> change) {
        _helper.handleListChange(sourceChange: change);
      },
      onCustom: (final S state) {
        _helper.reset();
        result.applyAction(StateOf<ObservableListUpdateAction<E>, S>.custom(state));
      },
    );
  }
}
