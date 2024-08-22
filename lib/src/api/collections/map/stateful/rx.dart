import '../../../../../dart_observable.dart';
import '../rx_actions.dart';

abstract interface class RxMapStateful<Self extends ObservableMapStateful<Self, K, V, S>, K, V, S>
    implements ObservableMapStateful<Self, K, V, S>, RxMapActions<K, V> {
  StateOf<ObservableMapChange<K, V>, S>? applyAction(
    final StateOf<ObservableMapUpdateAction<K, V>, S> action,
  );

  ObservableMapChange<K, V>? applyMapUpdateAction(final ObservableMapUpdateAction<K, V> action);

  StateOf<ObservableMapChange<K, V>, S>? setState(final S newState);
}
