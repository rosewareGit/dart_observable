import '../../../../../dart_observable.dart';
import '../../../../../src/core/collections/set/factories/from_collections.dart';
import '../../../../../src/core/collections/set/result.dart';

abstract interface class RxSetResult<E, F> implements ObservableSetResult<E, F>, Rx<ObservableSetResultState<E, F>> {
  factory RxSetResult({
    final Iterable<E>? initial,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return RxSetResultImpl<E, F>.custom(
      initial: initial,
      factory: factory,
    );
  }

  factory RxSetResult.failure({
    required final F failure,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return RxSetResultImpl<E, F>.failure(
      failure: failure,
      factory: factory,
    );
  }

  factory RxSetResult.fromCollections({
    required final Iterable<ObservableSetResultUpdater<E, F, dynamic>> observables,
    final FactorySet<E>? factory,
  }) {
    return ObservableSetFromCollections<E, F>(
      observables: observables,
      factory: factory,
    );
  }

  factory RxSetResult.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  }) {
    return RxSetResultImpl<E, F>.splayTreeSet(compare: compare, initial: initial);
  }

  factory RxSetResult.undefined({
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    return RxSetResultImpl<E, F>(factory: factory);
  }

  set data(final Set<E> data);

  set failure(final F failure);

  void add(final E item);

  void addAll(final Iterable<E> items);

  void applyAction(final ObservableSetResultUpdateAction<E, F> action);

  void remove(final E item);

  void removeWhere(final bool Function(E item) predicate);

  void setUndefined();
}
