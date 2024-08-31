import '../../../../../dart_observable.dart';

abstract class ObservableMapStateful<Self extends ObservableMapStateful<Self, K, V, S>, K, V, S>
    implements ObservableCollectionStateful<Self, ObservableMapChange<K, V>, S, ObservableMapStatefulState<K, V, S>> {
  StateOf<int, S> get length;

  int? get lengthOrNull;

  V? operator [](final K key);

  Self changeFactory(final FactoryMap<K, V> factory);

  bool containsKey(final K key);

  Self filterItem(
    final bool Function(K key, V value) predicate, {
    final FactoryMap<K, V>? factory,
  });

  Observable<StateOf<V?, S>> rxItem(final K key);

  List<V>? toList();
}
