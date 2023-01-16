import '../../../../src/core/collections/set/set.dart';
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

  set data(final Set<E> data);

  void add(final E item);

  void addAll(final Iterable<E> items);

  void applyAction(final ObservableSetUpdateAction<E> action);

  void remove(final E item);

  void removeWhere(final bool Function(E item) predicate);
}
