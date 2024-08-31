import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';
import '../../operators/map_item.dart';

class OperatorStatefulSetMapItem<Self extends RxSetStateful<O2, E2, S>, O2 extends ObservableSetStateful<O2, E2, S>,
    O extends ObservableSetStateful<O, E, S>, E, E2, S> {
  final O source;
  final Self result;
  final E2 Function(E item) mapper;

  late final BaseCollectionTransformOperatorProxy<O, ObservableSetStatefulState<E, S>, ObservableSetStatefulState<E, S>,
          StateOf<ObservableSetChange<E>, S>, StateOf<ObservableSetChange<E>, S>> proxy =
      BaseCollectionTransformOperatorProxy<O, ObservableSetStatefulState<E, S>, ObservableSetStatefulState<E, S>,
          StateOf<ObservableSetChange<E>, S>, StateOf<ObservableSetChange<E>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  OperatorStatefulSetMapItem({
    required this.source,
    required this.mapper,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableSetChange<E>, S> change) {
    change.fold(
      onData: (final ObservableSetChange<E> change) {
        ObservableSetMapItemOperator.mapChange<E, E2>(
          change,
          result.applySetUpdateAction,
          mapper,
        );
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableSetUpdateAction<E2>, S>.custom(state));
      },
    );
  }
}
