import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../../core/collections/list/factories/merged.dart';
import '../../../core/collections/list/factories/stream.dart';

/// Immutable list that can be observed for changes.
/// Each change is represented as a [ObservableListChange] object.
abstract interface class ObservableList<E> implements ObservableCollection<List<E>, ObservableListChange<E>> {
  /// Creates an [ObservableList] from a [Stream] of [ObservableListUpdateAction].
  /// Action is used to manipulate the list.
  /// When onError is provided, it will be called when an error occurs, otherwise the error will be thrown to the downstream.
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

  /// Creates an immutable [ObservableList] from the provided [value] items.
  factory ObservableList.just(final List<E> value) {
    return RxList<E>(value);
  }

  /// Creates an [ObservableList] from the provided [collections].
  /// Any change in the provided collections will be reflected in the merged list.
  /// The merged list is immutable.
  factory ObservableList.merged({
    required final Iterable<ObservableList<E>> collections,
  }) {
    return ObservableListMerged<E>(collections: collections);
  }

  int get length;

  @override
  UnmodifiableListView<E> get value;

  E? operator [](final int position);

  ObservableList<E> filterItem(final bool Function(E item) predicate);

  ObservableList<E2> mapItem<E2>(final E2 Function(E item) mapper);

  Observable<E?> rxItem(final int position);

  ObservableList<E> sorted(final Comparator<E> comparator);
}
