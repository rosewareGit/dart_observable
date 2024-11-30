class ObservableListElement<E> {
  ObservableListElement<E>? prevElement;
  ObservableListElement<E>? nextElement;

  E value;

  ObservableListElement({
    required this.value,
    required final ObservableListElement<E>? previousElement,
    required this.nextElement,
  }) : prevElement = previousElement;

  void unlink() {
    final ObservableListElement<E>? prev = prevElement;
    final ObservableListElement<E>? next = nextElement;

    if (prev != null) {
      prev.nextElement = next;
    }
    if (next != null) {
      next.prevElement = prev;
    }
  }
}
