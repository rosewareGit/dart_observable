import '../update_action.dart';
import 'observable.dart';

abstract interface class RxListResult<E, F> implements ObservableListResult<E, F> {
  set failure(final F failure);

  void operator []=(final int index, final E value);

  void add(final E item);

  void addAll(final Iterable<E> items);

  void applyAction(final ObservableListUpdateAction<E> action);

  void insert(final int index, final E item);

  void insertAll(final int index, final Iterable<E> items);

  void remove(final E item);

  void removeAt(final int index);

  void removeWhere(final bool Function(E item) predicate);

  void setUndefined();
}
