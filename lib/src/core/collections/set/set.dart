import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/base_tracking.dart';
import '../_base.dart';
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

class RxSetImpl<E> extends RxBaseTracking<ObservableSet<E>, ObservableSetState<E>, ObservableSetChange<E>>
    with
        ObservableCollectionBase<ObservableSet<E>, E, ObservableSetChange<E>, ObservableSetState<E>>,
        RxSetActionsImpl<E>
    implements RxSet<E> {
  // TODO check usage
  final Set<E> Function(Iterable<E>? items) _factory;

  RxSetImpl({
    final Iterable<E>? initial,
    final Set<E> Function(Iterable<E>? items)? factory,
  })  : _factory = factory ?? defaultSetFactory<E>(),
        super(
          RxSetState<E>.initial((factory ?? defaultSetFactory<E>()).call(initial)),
        );

  RxSetImpl.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  })  : _factory = _splayTreeSetFactory<E>(compare),
        super(
          RxSetState<E>.initial(_splayTreeSetFactory<E>(compare)(initial)),
        );

  @override
  Set<E>? get data => _value.data;

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
  bool contains(final E item) {
    return _value.data.contains(item);
  }

  @override
  Observable<E?> rxItem(final bool Function(E item) predicate) {
    return OperatorObservableSetRxItem<E>(
      source: this,
      predicate: predicate,
    );
  }

  @override
  ObservableSetChange<E>? setData(final Set<E> data) {
    final ObservableSetChange<E> change = ObservableSetChange<E>.fromDiff(_value.data, data);
    if (change.isEmpty) {
      return null;
    }

    this.value = RxSetState<E>(
      data,
      change,
    );
    return change;
  }

  @override
  List<E> toList() {
    return _value.data.toList();
  }

  @override
  ObservableSet<E> get self => this;
}
