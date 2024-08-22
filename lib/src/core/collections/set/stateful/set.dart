import '../../../../../dart_observable.dart';
import '../../../rx/base_tracking.dart';
import '../../_base.dart';
import '../rx_actions.dart';
import '../set.dart';
import '../set_state.dart';
import 'state.dart';

abstract class RxSetStatefulImpl<Self extends ObservableSetStateful<Self, E, S>, E, S>
    extends RxBaseTracking<Self, ObservableSetStatefulState<E, S>, StateOf<ObservableSetChange<E>, S>>
    with
        ObservableCollectionBase<
            Self,
            E, //
            StateOf<ObservableSetChange<E>, S>,
            ObservableSetStatefulState<E, S>>,
        RxSetActionsImpl<E>
    implements
        RxSetStateful<Self, E, S> {
  final FactorySet<E> _factory;

  RxSetStatefulImpl(
    super.value, {
    final FactorySet<E>? factory,
  }) : _factory = factory ?? defaultSetFactory<E>();

  @override
  Set<E>? get data => value.fold(
        onData: (final ObservableSetState<E> data) => data.setView,
        onCustom: (final _) => null,
      );

  @override
  StateOf<int, S> get length => value.fold(
        onData: (final ObservableSetState<E> data) => StateOf<int, S>.data(data.setView.length),
        onCustom: (final S state) => StateOf<int, S>.custom(state),
      );

  @override
  int? get lengthOrNull => length.data;

  @override
  StateOf<ObservableSetChange<E>, S>? applyAction(
    final StateOf<ObservableSetUpdateAction<E>, S> action,
  ) {
    final ObservableSetStatefulState<E, S> currentValue = value;
    return action.fold<StateOf<ObservableSetChange<E>, S>?>(
      onData: (final ObservableSetUpdateAction<E> updateAction) {
        return currentValue.fold(
          onData: (final ObservableSetState<E> data) {
            final RxSetState<E> state = data as RxSetState<E>;
            final Set<E> updatedSet = state.data;
            final ObservableSetChange<E> change = updateAction.apply(updatedSet);

            if (change.isEmpty) {
              return null;
            }

            final RxSetStatefulState<E, S> newState = RxSetStatefulState<E, S>.data(
              RxSetState<E>(updatedSet, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
          onCustom: (final S state) {
            final Set<E> updatedSet = _factory(<E>[]);
            final ObservableSetChange<E> change = updateAction.apply(updatedSet);

            final RxSetStatefulState<E, S> newState = RxSetStatefulState<E, S>.data(
              RxSetState<E>(updatedSet, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
        );
      },
      onCustom: (final S action) {
        final RxSetStatefulState<E, S> newState = RxSetStatefulState<E, S>.custom(action);
        super.value = newState;
        return newState.lastChange;
      },
    );
  }

  @override
  ObservableSetChange<E>? applySetUpdateAction(final ObservableSetUpdateAction<E> action) {
    return applyAction(
      StateOf<ObservableSetUpdateAction<E>, S>.data(action),
    )?.data;
  }

  @override
  bool contains(E item) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  Observable<StateOf<E?, S>> rxItem(final bool Function(E item) predicate) {
    // TODO
    throw UnimplementedError();
  }

  @override
  ObservableSetChange<E>? setData(Set<E> data) {
    // TODO: implement setData
    throw UnimplementedError();
  }

  @override
  StateOf<ObservableSetChange<E>, S>? setState(final S newState) {
    return applyAction(StateOf<ObservableSetUpdateAction<E>, S>.custom(newState));
  }
}
