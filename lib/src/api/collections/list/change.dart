import '../item_change.dart';

class ObservableListChange<E> {
  final Map<int, E> added;
  final Map<int, E> removed;
  final Map<int, ObservableItemChange<E>> updated;

  ObservableListChange({
    final Map<int, E>? added,
    final Map<int, E>? removed,
    final Map<int, ObservableItemChange<E>>? updated,
  })  : added = added ?? <int, E>{},
        removed = removed ?? <int, E>{},
        updated = updated ?? <int, ObservableItemChange<E>>{};

  bool get isEmpty => added.isEmpty && removed.isEmpty && updated.isEmpty;
}
