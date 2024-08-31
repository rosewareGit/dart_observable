import '../../../../../dart_observable.dart';
import '../rx_actions.dart';

abstract interface class RxSetStateful<Self extends ObservableSetStateful<Self, E, S>, E, S>
    implements ObservableSetStateful<Self, E, S>, RxSetActions<E> {
  StateOf<ObservableSetChange<E>, S>? applyAction(
    final StateOf<ObservableSetUpdateAction<E>, S> action,
  );

  ObservableSetChange<E>? applySetUpdateAction(final ObservableSetUpdateAction<E> action);

  Self asObservable();

  StateOf<ObservableSetChange<E>, S>? setState(final S newState);
}
