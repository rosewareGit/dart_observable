import 'dart:collection';

import '../../../../../dart_observable.dart';
import '../../_base_stateful.dart';
import '../change_elements.dart';
import '../list_element.dart';
import '../list_state.dart';
import '../rx_actions.dart';
import '../update_action_handler.dart';
import 'operators/filter_item.dart';
import 'operators/filter_item_state.dart';
import 'operators/map_item.dart';
import 'operators/map_item_state.dart';
import 'operators/rx_item.dart';
import 'operators/sorted.dart';

class RxStatefulListImpl<E, S> extends RxCollectionStatefulBase<List<E>, ObservableListChange<E>, S>
    with RxListActionsImpl<E>, ObservableListUpdateActionHandlerImpl<E>
    implements RxStatefulList<E, S>, ObservableListUpdateActionHandler<E> {
  late Either<ObservableListChangeElements<E>, S> _change;

  final Rx<Either<RxListState<E>, S>> _rxState;

  RxStatefulListImpl(final List<E> data)
      : this.state(
          Either<List<E>, S>.left(data),
        );

  factory RxStatefulListImpl.custom(final S state) {
    return RxStatefulListImpl<E, S>.state(
      Either<List<E>, S>.right(state),
    );
  }

  RxStatefulListImpl.state(final Either<List<E>, S> state)
      : _rxState = Rx<Either<RxListState<E>, S>>(
          state.fold(
            onLeft: (final List<E> data) => Either<RxListState<E>, S>.left(RxListState<E>.fromData(data)),
            onRight: (final S state) => Either<RxListState<E>, S>.right(state),
          ),
        ),
        super(state) {
    _change = currentStateAsChange;
  }

  @override
  Either<ObservableListChangeElements<E>, S> get change => _change;

  @override
  Either<ObservableListChangeElements<E>, S> get currentStateAsChange {
    return _rxState.value.fold(
      onLeft: (final RxListState<E> state) {
        return Either<ObservableListChangeElements<E>, S>.left(
          ObservableListChangeElements<E>(
            added: <int, ObservableListElement<E>>{
              for (int i = 0; i < state.data.length; i++) i: state.data[i],
            },
          ),
        );
      },
      onRight: (final S custom) {
        return Either<ObservableListChangeElements<E>, S>.right(custom);
      },
    );
  }

  @override
  List<ObservableListElement<E>> get data => _rxState.value.fold(
        onLeft: (final RxListState<E> state) => state.data,
        onRight: (final _) => <ObservableListElement<E>>[],
      );

  @override
  int? get length => _rxState.value.fold(
        onLeft: (final RxListState<E> state) => state.data.length,
        onRight: (final S state) => null,
      );

  Either<RxListState<E>, S>? get previousState => _rxState.previous;

  @override
  Either<List<E>, S> get value {
    return _rxState.value.fold(
      onLeft: (final RxListState<E> state) => Either<List<E>, S>.left(state.listView),
      onRight: (final S custom) => Either<List<E>, S>.right(custom),
    );
  }

  @override
  set value(final Either<List<E>, S> value) {
    value.fold(
      onLeft: (final List<E> data) {
        setData(data);
      },
      onRight: (final S state) {
        setState(state);
      },
    );
  }

  @override
  E? operator [](final int position) {
    return _rxState.value.fold(
      onLeft: (final RxListState<E> state) {
        final UnmodifiableListView<E> currentData = state.listView;
        if (position < 0 || position >= currentData.length) {
          return null;
        }
        return currentData[position];
      },
      onRight: (final _) => null,
    );
  }

  Either<ObservableListChangeElements<E>, S>? applyAction(
    final StatefulListAction<E,S> action,
  ) {
    final Either<RxListState<E>, S> currentState = _rxState.value;

    return action.fold<Either<ObservableListChangeElements<E>, S>?>(
      onLeft: (final ObservableListUpdateAction<E> listUpdateAction) {
        return currentState.fold(
          onLeft: (final RxListState<E> state) {
            final List<ObservableListElement<E>> updatedList = state.data;
            final (List<ObservableListElement<E>>, ObservableListChangeElements<E>) result =
                handleListUpdateAction(updatedList, listUpdateAction);

            if (result.$2.isEmpty) {
              return null;
            }

            state.onUpdated();

            _change = Either<ObservableListChangeElements<E>, S>.left(result.$2);
            notify();
            return _change;
          },
          onRight: (final S state) {
            final (List<ObservableListElement<E>> data, ObservableListChangeElements<E> change) result =
                handleListUpdateAction(data, listUpdateAction);

            final RxListState<E> rxListState = RxListState<E>(result.$1);
            _rxState.value = Either<RxListState<E>, S>.left(rxListState);

            rxListState.onUpdated();
            _change = Either<ObservableListChangeElements<E>, S>.left(result.$2);
            super.value = Either<List<E>, S>.left(rxListState.listView);
            return _change;
          },
        );
      },
      onRight: (final S action) {
        _rxState.value = Either<RxListState<E>, S>.right(action);
        _change = Either<ObservableListChangeElements<E>, S>.right(action);
        super.value = Either<List<E>, S>.right(action);
        return _change;
      },
    );
  }

  @override
  ObservableListChangeElements<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(
      StatefulListAction<E,S>.left(action),
    )?.leftOrNull;
  }

  @override
  ObservableStatefulList<E, S> filterItem(final bool Function(E item) predicate) {
    return StatefulListFilterOperator<E, S>(
      source: this,
      predicate: predicate,
    );
  }

  @override
  ObservableStatefulList<E, S> filterItemWithState(final bool Function(Either<E, S> item) predicate) {
    return OperatorStatefulListFilterItemState<E, S>(
      source: this,
      predicate: predicate,
    );
  }

  @override
  ObservableStatefulList<E2, S> mapItem<E2>(final E2 Function(E item) mapper) {
    return OperatorStatefulListMapItem<E, E2, S>(
      source: this,
      mapper: mapper,
    );
  }

  @override
  ObservableStatefulList<E2, S2> mapItemWithState<E2, S2>({
    required final E2 Function(E item) mapper,
    required final S2 Function(S state) stateMapper,
  }) {
    return OperatorStatefulListMapItemState<E, E2, S, S2>(
      source: this,
      mapper: mapper,
      stateMapper: stateMapper,
    );
  }

  @override
  void onEmptyData() {
    final Either<RxListState<E>, S> current = _rxState.value;
    current.when(
      onRight: (final S custom) {
        // transition to data state
        final RxListState<E> newState = RxListState<E>(<ObservableListElement<E>>{});
        _rxState.value = Either<RxListState<E>, S>.left(newState);
        newState.onUpdated();
        super.value = Either<List<E>, S>.left(newState.listView);
      },
    );
  }

  @override
  void onSyncComplete(final ObservableListChangeElements<E> change) {
    final Either<RxListState<E>, S> current = _rxState.value;
    final RxListState<E>? left = current.leftOrNull;
    if (left != null) {
      if (change.isEmpty) {
        return;
      }
      _change = Either<ObservableListChangeElements<E>, S>.left(change);
      left.onUpdated();
      notify();
    } else {
      _change = Either<ObservableListChangeElements<E>, S>.left(change);
      final RxListState<E> newState = RxListState<E>(
        <ObservableListElement<E>>[
          for (final ObservableListElement<E> element in change.addedElements.values) element,
        ],
      );
      _rxState.value = Either<RxListState<E>, S>.left(newState);
      super.value = Either<List<E>, S>.left(newState.listView);
    }
  }

  @override
  Observable<Either<E?, S>> rxItem(final int position) {
    return OperatorObservableListStatefulRxItem<E, S>(
      source: this,
      position: position,
    );
  }

  @override
  void setDataWithChange(final List<ObservableListElement<E>> data, final ObservableListChangeElements<E> change) {
    _change = Either<ObservableListChangeElements<E>, S>.left(change);
    final RxListState<E> newState = RxListState<E>(data);
    _rxState.value = Either<RxListState<E>, S>.left(newState);
    super.value = Either<List<E>, S>.left(newState.listView);
  }

  @override
  StatefulListChange<E,S>? setState(final S newState) {
    return applyAction(StatefulListAction<E,S>.right(newState));
  }

  @override
  ObservableStatefulList<E, S> sorted(final Comparator<E> comparator) {
    return ObservableStatefulListSortedOperator<E, S>(
      source: this,
      comparator: comparator,
    );
  }
}
