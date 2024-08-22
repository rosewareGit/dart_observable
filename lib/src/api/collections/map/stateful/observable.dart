import '../../../../../dart_observable.dart';

abstract class ObservableMapStateful<Self extends ObservableMapStateful<Self, K, V, S>, K, V, S>
    implements
        ObservableCollectionStateful<
            Self,
            K, //
            ObservableMapChange<K, V>,
            S,
            ObservableMapStatefulState<K, V, S>> {
  StateOf<int, S> get length;

  int? get lengthOrNull;

  V? operator [](final K key);

  Observable<StateOf<V?, S>> rxItem(final K key);
}
