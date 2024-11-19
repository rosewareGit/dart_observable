import '../../../../dart_observable.dart';
import '../../../core/collections/list/factories/merged.dart';
import '../../../core/collections/list/factories/stream.dart';

abstract interface class ObservableList<E>
    implements ObservableCollection<ObservableListState<E>, ObservableListChange<E>> {
  factory ObservableList.fromStream({
    required final Stream<ObservableListUpdateAction<E>> stream,
    final List<E>? initial,
    final List<E>? Function(dynamic error)? onError,
  }) {
    return ObservableListFromStream<E>(
      stream: stream,
      initial: initial,
      onError: onError,
    );
  }

  factory ObservableList.just(final List<E> value) {
    return RxList<E>(value);
  }

  factory ObservableList.merged({
    required final Iterable<ObservableList<E>> collections,
  }) {
    return ObservableListMerged<E>(
      collections: collections,
    );
  }

  int get length;

  E? operator [](final int position);

  ObservableList<E> filterItem(final bool Function(E item) predicate);

  ObservableList<E2> mapItem<E2>(final E2 Function(E item) mapper);

  Observable<E?> rxItem(final int position);

  ObservableList<E> sorted(final Comparator<E> comparator);
}
