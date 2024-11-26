import '../../../../../dart_observable.dart';
import '../../../../core/collections/list/stateful/factories/merged.dart';
import '../../../../core/collections/list/stateful/factories/stream.dart';

abstract class ObservableStatefulList<E, S>
    implements
        ObservableCollectionStateful<
            ObservableListChange<E>, // the collection change type
            S, // The custom state
            Either<List<E>, S> // The state type
            > {
  factory ObservableStatefulList.custom(final S custom) {
    return RxStatefulList<E, S>.custom(custom);
  }

  factory ObservableStatefulList.fromStream({
    required final Stream<Either<ObservableListUpdateAction<E>, S>> stream,
    final Either<List<E>, S>? initial,
    final Either<List<E>, S> Function(dynamic error)? onError,
  }) {
    return ObservableStatefulListFromStream<E, S>(
      stream: stream,
      initial: initial,
      onError: onError,
    );
  }

  factory ObservableStatefulList.just(final List<E> data) {
    return RxStatefulList<E, S>(initial: data);
  }

  factory ObservableStatefulList.merged({
    required final Iterable<ObservableStatefulList<E, S>> collections,
    final Either<List<E>, S>? Function(S state)? stateResolver,
  }) {
    return ObservableStatefulListMerged<E, S>(
      collections: collections,
      stateResolver: stateResolver,
    );
  }

  int? get length;

  E? operator [](final int position);

  ObservableStatefulList<E, S> filterItem(final bool Function(E item) predicate);

  ObservableStatefulList<E, S> filterItemWithState(final bool Function(Either<E, S> item) predicate);

  ObservableStatefulList<E2, S> mapItem<E2>(final E2 Function(E item) mapper);

  ObservableStatefulList<E2, S2> mapItemWithState<E2, S2>({
    required final E2 Function(E item) mapper,
    required final S2 Function(S state) stateMapper,
  });

  Observable<Either<E?, S>> rxItem(final int position);

  ObservableStatefulList<E, S> sorted(final Comparator<E> comparator);
}
