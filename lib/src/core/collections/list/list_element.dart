class ObservableListElement<E> {
  ObservableListElement<E>? _prev;
  ObservableListElement<E>? nextElement;

  E value;

  ObservableListElement({
    required this.value,
    required final ObservableListElement<E>? previousElement,
    required this.nextElement,
  }) : _prev = previousElement;

  ObservableListElement<E>? get previousElement => _prev;

  void unlink() {
    final ObservableListElement<E>? prev = _prev;
    final ObservableListElement<E>? next = nextElement;

    if (prev != null) {
      prev.nextElement = next;
    }
    if (next != null) {
      next._prev = prev;
    }
  }
}
