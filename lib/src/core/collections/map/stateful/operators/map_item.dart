import '../../../../../../dart_observable.dart';
import '../../../operators/_base_transform_proxy.dart';
import '../../operators/map_item.dart';

class OperatorStatefulMapMapItem<Self extends RxMapStateful<O2, K, V2, S>,
    O2 extends ObservableMapStateful<O2, K, V2, S>, O extends ObservableMapStateful<O, K, V, S>, K, V, V2, S> {
  final O source;
  final Self result;
  final V2 Function(K key, V value) mapper;

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

  OperatorStatefulMapMapItem({
    required this.source,
    required this.mapper,
    required final Self Function() instanceBuilder,
  }) : result = instanceBuilder() {
    proxy.init();
  }

  void transformChange(final StateOf<ObservableMapChange<K, V>, S> change) {
    change.fold(
      onData: (final ObservableMapChange<K, V> change) {
        OperatorMapMap.mapChange<K, V, V2>(
          change,
          result.applyMapUpdateAction,
          mapper,
        );
      },
      onCustom: (final S state) {
        result.applyAction(StateOf<ObservableMapUpdateAction<K, V2>, S>.custom(state));
      },
    );
  }
}
