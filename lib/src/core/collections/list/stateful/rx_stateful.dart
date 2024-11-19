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
import 'state.dart';

class RxStatefulListImpl<E, S> extends RxCollectionStatefulBase<ObservableListState<E>,
        ObservableStatefulListState<E, S>, ObservableListChange<E>, S>
    with RxListActionsImpl<E>, ObservableListUpdateActionHandlerImpl<E>
    implements RxStatefulList<E, S>, ObservableListUpdateActionHandler<E> {
  late Either<ObservableListChangeElements<E>, S> _change;

  RxStatefulListImpl(final List<E> data)
      : this.state(
          RxStatefulListState<E, S>.fromState(RxListState<E>.fromData(data)),
        );

  factory RxStatefulListImpl.custom(final S state) {
    return RxStatefulListImpl<E, S>.state(
      RxStatefulListState<E, S>.custom(state),
    );
  }

  RxStatefulListImpl.state(final ObservableStatefulListState<E, S> state) : super(state) {
    _change = currentStateAsChange;
  }

  @override
  Either<ObservableListChangeElements<E>, S> get change => _change;

  @override
  Either<ObservableListChangeElements<E>, S> get currentStateAsChange {
    return value.fold(
      onData: (final ObservableListState<E> data) {
        return Either<ObservableListChangeElements<E>, S>.left(
          ObservableListChangeElements<E>(
            added: <int, ObservableListElement<E>>{
              for (int i = 0; i < data.listView.length; i++) i: (data as RxListState<E>).data[i],
            },
          ),
        );
      },
      onCustom: (final S custom) {
        return Either<ObservableListChangeElements<E>, S>.right(custom);
      },
    );
  }

  @override
  List<ObservableListElement<E>> get data => value.fold(
        onData: (final ObservableListState<E> data) => (data as RxListState<E>).data,
        onCustom: (final _) => <ObservableListElement<E>>[],
      );

  @override
  int? get length => value.fold(
        onData: (final ObservableListState<E> data) => data.listView.length,
        onCustom: (final S state) => null,
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
  Either<ObservableListChangeElements<E>, S>? applyAction(
    final Either<ObservableListUpdateAction<E>, S> action,
  ) {
    final ObservableStatefulListState<E, S> currentValue = value;
    return action.fold<Either<ObservableListChangeElements<E>, S>?>(
      onLeft: (final ObservableListUpdateAction<E> listUpdateAction) {
        return currentValue.fold(
          onData: (final ObservableListState<E> data) {
            final RxListState<E> state = data as RxListState<E>;
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
          onCustom: (final S state) {
            final (List<ObservableListElement<E>> data, ObservableListChangeElements<E> change) result =
                handleListUpdateAction(data, listUpdateAction);

            final RxListState<E> rxListState = RxListState<E>(result.$1);
            final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.fromState(
              rxListState,
            );

            rxListState.onUpdated();
            _change = Either<ObservableListChangeElements<E>, S>.left(result.$2);
            super.value = newState;
            return _change;
          },
        );
      },
      onRight: (final S action) {
        final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.custom(action);
        _change = Either<ObservableListChangeElements<E>, S>.right(action);
        super.value = newState;
        return _change;
      },
    );
  }

  @override
  ObservableListChangeElements<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(
      Either<ObservableListUpdateAction<E>, S>.left(action),
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
    final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.fromState(
      RxListState<E>(<ObservableListElement<E>>{}),
    );

    super.value = newState;
  }

  @override
  void onSyncComplete(final ObservableListChangeElements<E> change) {
    final RxStatefulListState<E, S> value = this.value as RxStatefulListState<E, S>;
    final ObservableListState<E>? left = value.leftOrNull;
    if (left != null) {
      if (change.isEmpty) {
        return;
      }
      _change = Either<ObservableListChangeElements<E>, S>.left(change);
      (left as RxListState<E>).onUpdated();
      notify();
    } else {
      _change = Either<ObservableListChangeElements<E>, S>.left(change);
      super.value = RxStatefulListState<E, S>.fromState(
        RxListState<E>(<ObservableListElement<E>>[
          for (final ObservableListElement<E> element in change.addedElements.values) element,
        ]),
      );
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
    super.value = RxStatefulListState<E, S>.fromState(RxListState<E>(data));
  }

  @override
  Either<ObservableListChange<E>, S>? setState(final S newState) {
    return applyAction(Either<ObservableListUpdateAction<E>, S>.right(newState));
  }

  @override
  ObservableStatefulList<E, S> sorted(final Comparator<E> comparator) {
    return ObservableStatefulListSortedOperator<E, S>(
      source: this,
      comparator: comparator,
    );
  }
}
