import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';

class OperatorStatefulMapChangeFactory<Self extends RxMapStateful<O, K, V, S>,
    O extends ObservableMapStateful<O, K, V, S>, K, V, S> {
  final O source;

  final Self result;

  late final BaseCollectionTransformOperatorProxy<
          O,
          ObservableMapStatefulState<K, V, S>,
          ObservableMapStatefulState<K, V, S>,
          StateOf<ObservableMapChange<K, V>, S>,
          StateOf<ObservableMapChange<K, V>, S>> proxy =
      BaseCollectionTransformOperatorProxy<O, ObservableMapStatefulState<K, V, S>, ObservableMapStatefulState<K, V, S>,
          StateOf<ObservableMapChange<K, V>, S>, StateOf<ObservableMapChange<K, V>, S>>(
    current: result,
    source: source,
    transformChange: transformChange,
  );

  OperatorStatefulMapChangeFactory({
    required this.source,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableMapChange<K, V>, S> change) {
    change.fold(
      onData: (final ObservableMapChange<K, V> change) {
        result.applyAction(
          StateOf<ObservableMapUpdateAction<K, V>, S>.data(ObservableMapUpdateAction<K, V>.fromChange(change)),
        );
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableMapUpdateAction<K, V>, S>.custom(state));
      },
    );
  }
}
