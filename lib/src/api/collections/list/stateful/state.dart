import '../../../../../dart_observable.dart';

abstract class ObservableListStatefulState<E, S> extends StateOf<ObservableListState<E>, S>
    implements CollectionState<StateOf<ObservableListChange<E>, S>> {
  const ObservableListStatefulState.custom(super.custom) : super.custom();

  const ObservableListStatefulState.data(super.data) : super.data();

  @override
  StateOf<ObservableListChange<E>, S> get lastChange {
    return fold(
      onData: (final ObservableListState<E> state) => StateOf<ObservableListChange<E>, S>.data(state.lastChange),
      onCustom: (final S state) => StateOf<ObservableListChange<E>, S>.custom(state),
    );
  }

  @override
  StateOf<ObservableListChange<E>, S> asChange() {
    return fold(
      onData: (final ObservableListState<E> state) => StateOf<ObservableListChange<E>, S>.data(state.asChange()),
      onCustom: (final S state) => StateOf<ObservableListChange<E>, S>.custom(state),
    );
  }
}
