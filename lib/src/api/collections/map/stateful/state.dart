import '../../../../../dart_observable.dart';

abstract class ObservableMapStatefulState<K, V, S> extends StateOf<ObservableMapState<K, V>, S>
    implements CollectionState<StateOf<ObservableMapChange<K, V>, S>> {
  const ObservableMapStatefulState.custom(super.custom) : super.custom();

  const ObservableMapStatefulState.data(super.data) : super.data();

  @override
  StateOf<ObservableMapChange<K, V>, S> get lastChange {
    return fold(
      onData: (final ObservableMapState<K, V> state) => StateOf<ObservableMapChange<K, V>, S>.data(state.lastChange),
      onCustom: (final S state) => StateOf<ObservableMapChange<K, V>, S>.custom(state),
    );
  }

  @override
  StateOf<ObservableMapChange<K, V>, S> asChange() {
    return fold(
      onData: (final ObservableMapState<K, V> state) => StateOf<ObservableMapChange<K, V>, S>.data(state.asChange()),
      onCustom: (final S state) => StateOf<ObservableMapChange<K, V>, S>.custom(state),
    );
  }
}
