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

  factory ObservableListChange.fromDiff(
    final List<E> current,
    final List<E> newState,
  ) {
    final Map<int, E> added = <int, E>{};
    final Map<int, E> removed = <int, E>{};
    final Map<int, ObservableItemChange<E>> updated = <int, ObservableItemChange<E>>{};

    for (int i = 0; i < newState.length; i++) {
      if (i < current.length) {
        if (current[i] != newState[i]) {
          updated[i] = ObservableItemChange<E>(
            oldValue: current[i],
            newValue: newState[i],
          );
        }
      } else {
        added[i] = newState[i];
      }
    }

    for (int i = newState.length; i < current.length; i++) {
      removed[i] = current[i];
    }

    return ObservableListChange<E>(
      added: added,
      removed: removed,
      updated: updated,
    );
  }

  bool get isEmpty => added.isEmpty && removed.isEmpty && updated.isEmpty;
}
