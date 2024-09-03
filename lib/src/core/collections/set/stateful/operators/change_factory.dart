import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';

class OperatorStatefulSetChangeFactory<Self extends RxSetStateful<O, E, S>, O extends ObservableSetStateful<O, E, S>, E,
    S> {
  final O source;

  final Self result;

  late final BaseCollectionTransformOperatorProxy<ObservableSetStatefulState<E, S>, ObservableSetStatefulState<E, S>,
          StateOf<ObservableSetChange<E>, S>, StateOf<ObservableSetChange<E>, S>> proxy =
      BaseCollectionTransformOperatorProxy<ObservableSetStatefulState<E, S>, ObservableSetStatefulState<E, S>,
          StateOf<ObservableSetChange<E>, S>, StateOf<ObservableSetChange<E>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  OperatorStatefulSetChangeFactory({
    required this.source,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableSetChange<E>, S> change) {
    change.fold(
      onData: (final ObservableSetChange<E> change) {
        result.applyAction(
          StateOf<ObservableSetUpdateAction<E>, S>.data(ObservableSetUpdateAction<E>.fromChange(change)),
        );
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableSetUpdateAction<E>, S>.custom(state));
      },
    );
  }
}
