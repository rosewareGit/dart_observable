import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';
import '../../operators/map_item.dart';

class OperatorStatefulListMapItem<Self extends RxListStateful<O2, E2, S>, O2 extends ObservableListStateful<O2, E2, S>,
    O extends ObservableListStateful<O, E, S>, E, E2, S> {
  final O source;
  final Self result;
  final E2 Function(E item) mapper;

  late final BaseCollectionTransformOperatorProxy<O, ObservableListStatefulState<E, S>,
          ObservableListStatefulState<E, S>, StateOf<ObservableListChange<E>, S>, StateOf<ObservableListChange<E>, S>>
      proxy = BaseCollectionTransformOperatorProxy<O, ObservableListStatefulState<E, S>,
          ObservableListStatefulState<E, S>, StateOf<ObservableListChange<E>, S>, StateOf<ObservableListChange<E>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  OperatorStatefulListMapItem({
    required this.source,
    required this.mapper,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableListChange<E>, S> change) {
    change.fold(
      onData: (final ObservableListChange<E> change) {
        ObservableListMapItemOperator.mapChange<E, E2>(
          change,
          result.applyListUpdateAction,
          mapper,
        );
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableListUpdateAction<E2>, S>.custom(state));
      },
    );
  }
}
