import '../../../../../dart_observable.dart';

abstract class ObservableSetStatefulState<E, S> extends StateOf<ObservableSetState<E>, S>
    implements CollectionState<StateOf<ObservableSetChange<E>, S>> {
  const ObservableSetStatefulState.custom(super.custom) : super.custom();

  const ObservableSetStatefulState.data(super.data) : super.data();

  @override
  StateOf<ObservableSetChange<E>, S> get lastChange {
    return fold(
      onData: (final ObservableSetState<E> state) => StateOf<ObservableSetChange<E>, S>.data(state.lastChange),
      onCustom: (final S state) => StateOf<ObservableSetChange<E>, S>.custom(state),
    );
  }

  @override
  StateOf<ObservableSetChange<E>, S> asChange() {
    return fold(
      onData: (final ObservableSetState<E> state) => StateOf<ObservableSetChange<E>, S>.data(state.asChange()),
      onCustom: (final S state) => StateOf<ObservableSetChange<E>, S>.custom(state),
    );
  }
}
