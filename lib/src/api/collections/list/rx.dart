import '../../../core/collections/list/list.dart';
import 'observable.dart';
import 'update_action.dart';

abstract interface class RxList<E> implements ObservableList<E> {
  factory RxList([final Iterable<E>? initial, final List<E> Function(Iterable<E>? items)? factory]) {
    return RxListImpl<E>(initial: initial, factory: factory);
  }

  void operator []=(final int index, final E value);

  void add(final E item);

  void addAll(final Iterable<E> items);

  void applyAction(final ObservableListUpdateAction<E> action);

  void insert(final int index, final E item);

  void insertAll(final int index, final Iterable<E> items);

  void remove(final E item);

  void removeAt(final int index);

  void removeWhere(final bool Function(E item) predicate);
}
