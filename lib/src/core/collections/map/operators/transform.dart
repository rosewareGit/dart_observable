import '../../../../../dart_observable.dart';
import '../map.dart';

abstract class OperatorMapTransform<K, V, K2, V2> extends OperatorTransformAsMap<
    ObservableMap<K, V>, //
    ObservableMapChange<K, V>,
    ObservableMapState<K, V>,
    K2,
    V2> {
  OperatorMapTransform({
    required super.source,
    super.factory,
  });
}
