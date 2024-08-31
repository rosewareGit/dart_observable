import '../../../../../../dart_observable.dart';

abstract class ObservableMapUndefinedFailure<K, V, F>
    implements ObservableMapStateful<ObservableMapUndefinedFailure<K, V, F>, K, V, UndefinedFailure<F>> {
  ObservableMapUndefinedFailure<K, V2, F> mapItem<V2>(
    final V2 Function(K key, V value) valueMapper, {
    final FactoryMap<K, V2>? factory,
  });
}
