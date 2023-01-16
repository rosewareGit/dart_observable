class ObservableSetChange<E> {
  ObservableSetChange({
    final Set<E>? added,
    final Set<E>? removed,
  })  : added = added ?? <E>{},
        removed = removed ?? <E>{};

  final Set<E> added;
  final Set<E> removed;

  bool get isEmpty => added.isEmpty && removed.isEmpty;

  factory ObservableSetChange.fromDiff(
    final Set<E> previous,
    final Set<E> current,
  ) {
    final Set<E> added = current.difference(previous);
    final Set<E> removed = previous.difference(current);

    return ObservableSetChange<E>(
      added: added,
      removed: removed,
    );
  }

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
