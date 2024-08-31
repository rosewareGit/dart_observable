import '../../../../../dart_observable.dart';
import '../../../rx/base_tracking.dart';
import '../../_base.dart';
import '../list_state.dart';
import '../rx_actions.dart';
import '../rx_impl.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/rx_item.dart';
import 'state.dart';

abstract class RxListStatefulImpl<Self extends RxListStateful<O, E, S>, O extends ObservableListStateful<O, E, S>, E, S>
    extends RxBaseTracking<O, ObservableListStatefulState<E, S>, StateOf<ObservableListChange<E>, S>>
    with
        ObservableCollectionBase<O, StateOf<ObservableListChange<E>, S>, ObservableListStatefulState<E, S>>,
        RxListActionsImpl<E>
    implements RxListStateful<O, E, S> {
  final FactoryList<E> _factory;

  RxListStatefulImpl(
    super.value, {
    final FactoryList<E>? factory,
  }) : _factory = factory ?? defaultListFactory<E>();

  @override
  List<E> get data => value.fold(
        onData: (final ObservableListState<E> data) => data.listView,
        onCustom: (final _) => _factory(<E>[]),
      );

  @override
  StateOf<int, S> get length => value.fold(
        onData: (final ObservableListState<E> data) => StateOf<int, S>.data(data.listView.length),
        onCustom: (final S state) => StateOf<int, S>.custom(state),
      );

  @override
  int? get lengthOrNull => length.data;

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

  @override
  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(
      StateOf<ObservableListUpdateAction<E>, S>.data(action),
    )?.data;
  }

  @override
  O asObservable() {
    return self;
  }

  Self builder({final List<E>? items, final FactoryList<E>? factory});

  @override
  O changeFactory(final FactoryList<E> factory) {
    final Self instance = builder(items: <E>[], factory: factory);
    OperatorStatefulListChangeFactory<Self, O, E, S>(
      source: self,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  O filterItem(
    final bool Function(E item) predicate, {
    final FactoryList<E>? factory,
  }) {
    final Self instance = builder(items: <E>[], factory: factory);
    OperatorStatefulListFilterItem<Self, O, E, S>(
      source: self,
      predicate: predicate,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  void onEmptyData() {
    final List<E> updatedList = _factory(<E>[]);
    final RxListStatefulState<E, S> newState = RxListStatefulState<E, S>.data(
      RxListState<E>(updatedList, ObservableListChange<E>()),
    );

    super.value = newState;
  }

  @override
  Observable<StateOf<E?, S>> rxItem(final int position) {
    return OperatorObservableListStatefulRxItem<O, E, S>(
      source: self,
      position: position,
    );
  }

  @override
  StateOf<ObservableListChange<E>, S>? setState(final S newState) {
    return applyAction(StateOf<ObservableListUpdateAction<E>, S>.custom(newState));
  }
}
