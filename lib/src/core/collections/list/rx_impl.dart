import '../../../../dart_observable.dart';
import '../_base.dart';
import 'change_elements.dart';
import 'list_element.dart';
import 'list_state.dart';
import 'operators/filter_item.dart';
import 'operators/map_item.dart';
import 'operators/rx_item.dart';
import 'operators/sorted.dart';
import 'rx_actions.dart';
import 'update_action_handler.dart';

class RxListImpl<E> extends RxCollectionBase<ObservableListState<E>, ObservableListChange<E>>
    with RxListActionsImpl<E>, ObservableListUpdateActionHandlerImpl<E>
    implements RxList<E>, ObservableListUpdateActionHandler<E> {
  late ObservableListChange<E> _change;

  RxListImpl({
    final Iterable<E>? initial,
  }) : super(RxListState<E>.fromData(initial ?? <E>[])) {
    _change = currentStateAsChange;
    _value.onUpdated();
  }

  @override
  ObservableListChange<E> get change => _change;

  @override
  ObservableListChangeElements<E> get currentStateAsChange {
    return ObservableListChangeElements<E>(
      added: <int, ObservableListElement<E>>{
        for (int i = 0; i < length; i++) i: data[i],
      },
    );
  }

  @override
  List<ObservableListElement<E>> get data => _value.data;

  @override
  int get length => data.length;

  RxListState<E> get _value => value as RxListState<E>;

  @override
  E? operator [](final int position) {
    final List<ObservableListElement<E>> data = _value.data;
    if (position < 0 || position >= data.length) return null;
    return data[position].value;
  }

  @override
  ObservableListChangeElements<E>? applyAction(final ObservableListUpdateAction<E> action) {
    if (action.isEmpty) {
      return null;
    }

    final (List<ObservableListElement<E>> data, ObservableListChangeElements<E> change) result =
        handleListUpdateAction(data, action);

    final ObservableListChangeElements<E> change = result.$2;
    if (change.isEmpty) {
      return null;
    }

    _change = change;
    _value.onUpdated();
    notify();
    return change;
  }

  @override
  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(action);
  }

  @override
  ObservableList<E> filterItem(final bool Function(E item) predicate) {
    return ObservableListFilterOperator<E>(
      predicate: predicate,
      source: this,
    );
  }

  @override
  ObservableList<E2> mapItem<E2>(final E2 Function(E item) mapper) {
    return ObservableListMapItemOperator<E, E2>(
      mapper: mapper,
      source: this,
    );
  }

  @override
  void onSyncComplete(final ObservableListChange<E> change) {
    if (change.isEmpty) {
      return;
    }
    _change = change;
    _value.onUpdated();
    notify();
  }

  @override
  Observable<E?> rxItem(final int position) {
    return OperatorObservableListRxItem<E>(
      source: this,
      index: position,
    );
  }

  @override
  void setDataWithChange(final List<ObservableListElement<E>> data, final ObservableListChangeElements<E> change) {
    _change = change;
    super.value = RxListState<E>(data);
  }

  @override
  ObservableList<E> sorted(final Comparator<E> comparator) {
    return ObservableListSortedOperator<E>(
      comparator: comparator,
      source: this,
    );
  }
}
