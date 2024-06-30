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

  void operator []=(final int index, final E value);

  ObservableListResultChange<E, F>? add(final E item);

  ObservableListResultChange<E, F>? addAll(final Iterable<E> items);

  ObservableListResultChange<E, F>? applyAction(final ObservableListResultUpdateAction<E, F> action);

  ObservableListResultChange<E, F>? clear();

  ObservableListResultChange<E, F>? insert(final int index, final E item);

  ObservableListResultChange<E, F>? insertAll(final int index, final Iterable<E> items);

  ObservableListResultChange<E, F>? remove(final E item);

  ObservableListResultChange<E, F>? removeAt(final int index);

  ObservableListResultChange<E, F>? removeWhere(final bool Function(E item) predicate);

  ObservableListResultChange<E, F>? setFailure(final F failure);

  ObservableListResultChange<E, F>? setUndefined();
}
