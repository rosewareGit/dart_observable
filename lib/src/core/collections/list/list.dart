import '../../../../dart_observable.dart';
import '../../rx/base_tracking.dart';
import '../_base.dart';
import '../operators/list/filter.dart';
import '../operators/list/rx_item.dart';
import 'list_state.dart';
import 'rx_actions.dart';

FactoryList<E> defaultListFactory<E>() {
  return (final Iterable<E>? items) {
    return List<E>.of(items ?? <E>{});
  };
}

class RxListImpl<E> extends RxBaseTracking<ObservableList<E>, ObservableListState<E>, ObservableListChange<E>>
    with
        ObservableCollectionBase<ObservableList<E>, E, ObservableListChange<E>, ObservableListState<E>>,
        RxListActionsImpl<E>
    implements RxList<E> {
  RxListImpl({
    final Iterable<E>? initial,
    final List<E> Function(Iterable<E>? items)? factory,
  }) : super(RxListState<E>.initial((factory ?? defaultListFactory<E>()).call(initial)));

  RxListState<E> get _value => value as RxListState<E>;

  @override
  List<E> get data => _value.data;

  @override
  E? operator [](final int position) {
    final List<E> data = _value.data;
    if (position < 0 || position >= data.length) return null;
    return data[position];
  }

  @override
  int get length => data.length;

  @override
  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(action);
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
  ObservableList<E> filterList({
    required final bool Function(E item) predicate,
    final FactoryList<E>? factory,
  }) {
    return ObservableListFilterOperator<E>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableList<E2> flatMapList<E2>({
    required final ObservableList<E2>? Function(
      ObservableListChange<E> change,
      ObservableList<E> source,
    ) sourceProvider,
    final FactoryList<E2>? factory,
  }) {
    throw UnimplementedError();
  }

  @override
  ObservableSet<E> mapAsSet({final FactorySet<E>? factory}) {
    // TODO: implement mapAsSet
    throw UnimplementedError();
  }

  @override
  Observable<E?> rxItem(final int position) {
    return OperatorObservableListRxItem<E>(
      source: this,
      index: position,
    );
  }

  @override
  ObservableList<E> get self => this;
}
