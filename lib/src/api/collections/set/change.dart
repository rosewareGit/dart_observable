class ObservableSetChange<E> {
  final Set<E> added;
  final Set<E> removed;

  ObservableSetChange({
    final Set<E>? added,
    final Set<E>? removed,
  })  : added = added ?? <E>{},
        removed = removed ?? <E>{};

  factory ObservableSetChange.fromDiff(
    final Set<E> current,
    final Set<E> updated,
  ) {
    final Set<E> added = updated.difference(current);
    final Set<E> removed = current.difference(updated);

    return ObservableSetChange<E>(
      added: added,
      removed: removed,
    );
  }

  bool get isEmpty => added.isEmpty && removed.isEmpty;

  static ObservableSetChange<E> fromAction<E>({
    required final Set<E> sourceToUpdate,
    required final Set<E> addItems,
    required final Set<E> removeItems,
  }) {
    final Set<E> added = <E>{};
    final Set<E> removed = <E>{};

    for (final E entry in removeItems) {
      if (sourceToUpdate.contains(entry)) {
        removed.add(entry);
      }
    }

    for (final E entry in addItems) {
      if (sourceToUpdate.contains(entry)) {
        continue;
      }
      added.add(entry);
    }

    sourceToUpdate.removeAll(removed);
    sourceToUpdate.addAll(added);

    return ObservableSetChange<E>(
      added: added,
      removed: removed,
    );
  }
}
