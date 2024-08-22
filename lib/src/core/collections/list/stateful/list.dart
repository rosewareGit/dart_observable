import '../../../../../dart_observable.dart';
import '../../../rx/base_tracking.dart';
import '../../_base.dart';
import '../../operators/list/stateful/rx_item.dart';
import '../list.dart';
import '../list_state.dart';
import '../rx_actions.dart';
import 'state.dart';

abstract class RxListStatefulImpl<Self extends ObservableListStateful<Self, E, S>, E, S>
    extends RxBaseTracking<Self, ObservableListStatefulState<E, S>, StateOf<ObservableListChange<E>, S>>
    with
        ObservableCollectionBase<
            Self,
            E, //
            StateOf<ObservableListChange<E>, S>,
            ObservableListStatefulState<E, S>>,
        RxListActionsImpl<E>
    implements
        RxListStateful<Self, E, S> {
  final FactoryList<E> _factory;

  RxListStatefulImpl(
    super.value, {
    final FactoryList<E>? factory,
  }) : _factory = factory ?? defaultListFactory<E>();

  @override
  List<E>? get data => value.fold(
        onData: (final ObservableListState<E> data) => data.listView,
        onCustom: (final _) => null,
      );

  @override
  E? operator [](final int position) {
    return value.fold(
      onData: (final ObservableListState<E> data) {
        final List<E> currentData = data.listView;
        if (position < 0 || position >= currentData.length) {
          return null;
        }
        return currentData[position];
      },
      onCustom: (final _) => null,
    );
  }

  @override
  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(
      StateOf<ObservableListUpdateAction<E>, S>.data(action),
    )?.data;
  }

  @override
  StateOf<int, S> get length => value.fold(
        onData: (final ObservableListState<E> data) => StateOf<int, S>.data(data.listView.length),
        onCustom: (final S state) => StateOf<int, S>.custom(state),
      );

  @override
  int? get lengthOrNull => length.data;

  @override
  StateOf<ObservableListChange<E>, S>? setState(final S newState) {
    return applyAction(StateOf<ObservableListUpdateAction<E>, S>.custom(newState));
  }

  @override
  Observable<StateOf<E?, S>> rxItem(final int position) {
    return OperatorObservableListStatefulRxItem<Self, E, S>(
      source: self,
      position: position,
    );
  }

  @override
  StateOf<ObservableListChange<E>, S>? applyAction(
    final StateOf<ObservableListUpdateAction<E>, S> action,
  ) {
    final ObservableListStatefulState<E, S> currentValue = value;
    return action.fold<StateOf<ObservableListChange<E>, S>?>(
      onData: (final ObservableListUpdateAction<E> listUpdateAction) {
        return currentValue.fold(
          onData: (final ObservableListState<E> data) {
            final RxListState<E> state = data as RxListState<E>;
            final List<E> updatedList = state.data;
            final ObservableListChange<E> change = listUpdateAction.apply(updatedList);

            if (change.isEmpty) {
              return null;
            }

            final RxListStatefulState<E, S> newState = RxListStatefulState<E, S>.data(
              RxListState<E>(updatedList, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
          onCustom: (final S state) {
            final List<E> updatedList = _factory(<E>[]);
            final ObservableListChange<E> change = listUpdateAction.apply(updatedList);

            final RxListStatefulState<E, S> newState = RxListStatefulState<E, S>.data(
              RxListState<E>(updatedList, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
        );
      },
      onCustom: (final S action) {
        final RxListStatefulState<E, S> newState = RxListStatefulState<E, S>.custom(action);
        super.value = newState;
        return newState.lastChange;
      },
    );
  }
}
