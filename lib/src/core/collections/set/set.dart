import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import 'operators/rx_item.dart';
import 'set_state.dart';

Set<E> Function(Iterable<E>? items) _defaultSetFactory<E>() {
  return (final Iterable<E>? items) {
    return Set<E>.of(items ?? <E>{});
  };
}

Set<E> Function(Iterable<E>? items) _splayTreeSetFactory<E>(final Comparator<E> compare) {
  return (final Iterable<E>? items) {
    return SplayTreeSet<E>.of(items ?? <E>{}, compare);
  };
}

class RxSetImpl<E> extends RxImpl<ObservableSetState<E>>
    with ObservableCollectionBase<E, ObservableSetChange<E>, ObservableSetState<E>>
    implements RxSet<E> {
  final Set<E> Function(Iterable<E>? items) _factory;

  RxSetImpl({
    final Iterable<E>? initial,
    final Set<E> Function(Iterable<E>? items)? factory,
  })  : _factory = factory ?? _defaultSetFactory<E>(),
        super(
          RxSetState<E>.initial((factory ?? _defaultSetFactory<E>()).call(initial)),
        );

  RxSetImpl.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  })  : _factory = _splayTreeSetFactory<E>(compare),
        super(
          RxSetState<E>.initial(_splayTreeSetFactory<E>(compare)(initial)),
        );

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
  int get length => _value.data.length;

  @override
  set value(final ObservableSetState<E> value) {
    super.value = RxSetState<E>(
      _factory(value.setView),
      ObservableSetChange<E>.fromDiff(
        _value.data,
        value.setView,
      ),
    );
  }

  RxSetState<E> get _value => value as RxSetState<E>;

  @override
  ObservableSetChange<E>? add(final E item) {
    return applyAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{item},
        removeItems: <E>{},
      ),
    );
  }

  @override
  ObservableSetChange<E>? addAll(final Iterable<E> items) {
    return applyAction(
      ObservableSetUpdateAction<E>(
        addItems: items.toSet(),
        removeItems: <E>{},
      ),
    );
  }

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
  bool contains(final E item) {
    return _value.data.contains(item);
  }

  @override
  ObservableSetChange<E>? remove(final E item) {
    return applyAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{},
        removeItems: <E>{item},
      ),
    );
  }

  @override
  ObservableSetChange<E>? removeWhere(final bool Function(E item) predicate) {
    final Set<E> removed = _value.data.where(predicate).toSet();
    if (removed.isEmpty) {
      return null;
    }

    return applyAction(
      ObservableSetUpdateAction<E>(
        addItems: <E>{},
        removeItems: removed,
      ),
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
