import '../../../../../dart_observable.dart';
import '../rx_actions.dart';

abstract interface class RxListStateful<
    Self extends ObservableListStateful<Self, E, S>, //
    E,
    S> implements ObservableListStateful<Self, E, S>, RxListActions<E> {
  StateOf<ObservableListChange<E>, S>? applyAction(
    final StateOf<ObservableListUpdateAction<E>, S> action,
  );

  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action);

  Self asObservable();

  StateOf<ObservableListChange<E>, S>? setState(final S newState);
}
