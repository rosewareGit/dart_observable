import '../../../../src/core/collections/set/set.dart';
import 'change.dart';
import 'observable.dart';
import 'update_action.dart';

abstract interface class RxSet<E> implements ObservableSet<E> {
  factory RxSet([final Iterable<E>? initial]) {
    return RxSetImpl<E>(initial: initial);
  }

  factory RxSet.custom({
    required final Set<E> Function(Iterable<E>? items) factory,
    final Iterable<E>? initial,
  }) {
    return RxSetImpl<E>(initial: initial, factory: factory);
  }

  factory RxSet.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  }) {
    return RxSetImpl<E>.splayTreeSet(initial: initial, compare: compare);
  }

  ObservableSetChange<E>? add(final E item);

  ObservableSetChange<E>? addAll(final Iterable<E> items);

  ObservableSetChange<E>? applyAction(final ObservableSetUpdateAction<E> action);

  ObservableSetChange<E>? remove(final E item);

  ObservableSetChange<E>? removeWhere(final bool Function(E item) predicate);

  ObservableSetChange<E>? setData(final Set<E> data);
}
