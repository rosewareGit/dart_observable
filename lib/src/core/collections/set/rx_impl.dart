import 'dart:collection';

import '../../../../dart_observable.dart';
import '../_base.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/map_item.dart';
import 'operators/rx_item.dart';
import 'rx_actions.dart';
import 'set_state.dart';

Set<E> Function(Iterable<E>? items) defaultSetFactory<E>() {
  return (final Iterable<E>? items) {
    return Set<E>.of(items ?? <E>{});
  };
}

Set<E> Function(Iterable<E>? items) _splayTreeSetFactory<E>(final Comparator<E> compare) {
  return (final Iterable<E>? items) {
    return SplayTreeSet<E>.of(items ?? <E>{}, compare);
  };
}

class RxSetImpl<E> extends RxCollectionBase<ObservableSetChange<E>, ObservableSetState<E>>
    with RxSetActionsImpl<E>
    implements RxSet<E> {
  RxSetImpl({
    final Iterable<E>? initial,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) : super(
          RxSetState<E>.initial((factory ?? defaultSetFactory<E>()).call(initial)),
        );

  RxSetImpl.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  }) : super(
          RxSetState<E>.initial(_splayTreeSetFactory<E>(compare)(initial)),
        );

  @override
  Set<E> get data => _value.data;

  @override
  int get length => _value.data.length;

  @override
  set value(final ObservableSetState<E> value) {
    setData(value.setView);
  }

  RxSetState<E> get _value => value as RxSetState<E>;

  @override
  ObservableSetChange<E>? applyAction(final ObservableSetUpdateAction<E> action) {
    final Set<E> updated = _value.data;
    final ObservableSetChange<E> change = action.apply(updated);
    if (change.isEmpty) {
      return null;
    }

    super.value = RxSetState<E>(
      updated,
      change,
    );
    return change;
  }

  @override
  ObservableSetChange<E>? applySetUpdateAction(final ObservableSetUpdateAction<E> action) {
    return applyAction(action);
  }

  @override
  ObservableSet<E> changeFactory(final FactorySet<E> factory) {
    return ObservableSetFactoryOperator<E>(
      source: this,
      factory: factory,
    );
  }

  @override
  bool contains(final E item) {
    return _value.data.contains(item);
  }

  @override
  ObservableSet<E> filterItem(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  }) {
    return ObservableSetFilterOperator<E>(
      predicate: predicate,
      source: this,
      factory: factory,
    );
  }

  @override
  ObservableSet<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  }) {
    return ObservableSetMapItemOperator<E, E2>(
      mapper: mapper,
      source: this,
      factory: factory,
    );
  }

  @override
  Observable<E?> rxItem(final bool Function(E item) predicate) {
    return OperatorObservableSetRxItem<E>(
      source: this,
      predicate: predicate,
    );
  }

  @override
  List<E> toList() {
    return _value.data.toList();
  }
}
