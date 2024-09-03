import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';

class OperatorStatefulListChangeFactory<Self extends RxListStateful<O, E, S>, O extends ObservableListStateful<O, E, S>,
    E, S> {
  final O source;

  final Self result;

  late final BaseCollectionTransformOperatorProxy<ObservableListStatefulState<E, S>, ObservableListStatefulState<E, S>,
          StateOf<ObservableListChange<E>, S>, StateOf<ObservableListChange<E>, S>> proxy =
      BaseCollectionTransformOperatorProxy<ObservableListStatefulState<E, S>, ObservableListStatefulState<E, S>,
          StateOf<ObservableListChange<E>, S>, StateOf<ObservableListChange<E>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  OperatorStatefulListChangeFactory({
    required this.source,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableListChange<E>, S> change) {
    change.fold(
      onData: (final ObservableListChange<E> change) {
        result.applyAction(
          StateOf<ObservableListUpdateAction<E>, S>.data(ObservableListUpdateAction<E>.fromChange(change)),
        );
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableListUpdateAction<E>, S>.custom(state));
      },
    );
  }
}
