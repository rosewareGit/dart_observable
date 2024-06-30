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

  ObservableSetResultChange<E, F>? add(final E item);

  ObservableSetResultChange<E, F>? addAll(final Iterable<E> items);

  ObservableSetResultChange<E, F>? applyAction(final ObservableSetResultUpdateAction<E, F> action);

  ObservableSetResultChange<E, F>? remove(final E item);

  ObservableSetResultChange<E, F>? removeWhere(final bool Function(E item) predicate);

  ObservableSetResultChange<E, F>? setData(final Set<E> data);

  ObservableSetResultChange<E, F>? setFailure(final F failure);

  ObservableSetResultChange<E, F>? setUndefined();
}
