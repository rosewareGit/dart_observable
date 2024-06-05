import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/result.dart';

abstract interface class RxListResult<E, F> implements ObservableListResult<E, F> {
  factory RxListResult({
    final Iterable<E>? initial,
    final List<E> Function(Iterable<E>? items)? factory,
  }) {
    return RxListResultImpl<E, F>.custom(
      initial: initial,
      factory: factory,
    );
  }

  set failure(final F failure);

  void operator []=(final int index, final E value);

  void add(final E item);

  void addAll(final Iterable<E> items);

  void applyAction(final ObservableListResultUpdateAction<E, F> action);

  void clear();

  void insert(final int index, final E item);

  void insertAll(final int index, final Iterable<E> items);

  void remove(final E item);

  void removeAt(final int index);

  void removeWhere(final bool Function(E item) predicate);

  void setUndefined();
}
