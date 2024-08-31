import '../../../../../../dart_observable.dart';

abstract class ObservableMapUndefined<K, V>
    implements ObservableMapStateful<ObservableMapUndefined<K, V>, K, V, Undefined> {
  ObservableMapUndefined<K, V2> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  });
}
