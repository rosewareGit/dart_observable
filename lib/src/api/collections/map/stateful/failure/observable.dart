import '../../../../../../dart_observable.dart';

abstract class ObservableMapFailure<K, V, F> implements ObservableMapStateful<ObservableMapFailure<K, V, F>, K, V, F> {
  ObservableMapFailure<K, V2, F> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  });
}
