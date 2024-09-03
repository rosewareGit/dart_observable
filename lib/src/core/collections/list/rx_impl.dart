import '../../../../dart_observable.dart';
import '../_base.dart';
import 'list_state.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/map_item.dart';
import 'operators/rx_item.dart';
import 'rx_actions.dart';

FactoryList<E> defaultListFactory<E>() {
  return (final Iterable<E>? items) {
    return List<E>.of(items ?? <E>{});
  };
}

class RxListImpl<E> extends RxBase<ObservableListState<E>>
    with
        ObservableCollectionBase<ObservableList<E>, ObservableListChange<E>, ObservableListState<E>>,
        RxListActionsImpl<E>
    implements RxList<E> {
  RxListImpl({
    final Iterable<E>? initial,
    final List<E> Function(Iterable<E>? items)? factory,
  }) : super(RxListState<E>.initial((factory ?? defaultListFactory<E>()).call(initial)));

  @override
  List<E> get data => _value.data;

  @override
  int get length => data.length;

  @override
  ObservableList<E> get self => this;

  RxListState<E> get _value => value as RxListState<E>;

  @override
  E? operator [](final int position) {
    final List<E> data = _value.data;
    if (position < 0 || position >= data.length) return null;
    return data[position];
  }

  @override
  ObservableListChange<E>? applyAction(final ObservableListUpdateAction<E> action) {
    if (action.isEmpty) {
      return null;
    }

    final List<E> updated = _value.data;
    final ObservableListChange<E> change = action.apply(updated);
    if (change.isEmpty) {
      return null;
    }
    value = RxListState<E>(
      updated,
      change,
    );
    return change;
  }

  @override
  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(action);
  }

  @override
  ObservableList<E> changeFactory(final FactoryList<E> factory) {
    return ObservableListFactoryOperator<E>(factory: factory, source: this);
  }

  @override
  ObservableList<E> filterItem(
    final bool Function(E item) predicate, {
    final FactoryList<E>? factory,
  }) {
    return ObservableListFilterOperator<E>(predicate: predicate, source: this);
  }

  @override
  ObservableList<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  }) {
    return ObservableListMapItemOperator<E, E2>(
      mapper: mapper,
      source: this,
      factory: factory,
    );
  }

  @override
  Observable<E?> rxItem(final int position) {
    return OperatorObservableListRxItem<E>(
      source: this,
      index: position,
    );
  }
}
