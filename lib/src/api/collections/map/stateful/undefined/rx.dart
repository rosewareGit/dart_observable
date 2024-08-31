import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/map/stateful/undefined/rx_impl.dart';

abstract class RxMapUndefined<K, V>
    implements ObservableMapUndefined<K, V>, RxMapStateful<ObservableMapUndefined<K, V>, K, V, Undefined> {
  factory RxMapUndefined({
    final Map<K, V>? initial,
    final FactoryMap<K, V>? factory,
  }) {
    return RxMapUndefinedImpl<K, V>(
      initial: initial,
      factory: factory,
    );
  }

  void setUndefined();
}
