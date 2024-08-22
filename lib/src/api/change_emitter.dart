abstract interface class ChangeEmitter<T, C> {
  C lastChange(final T state);

  C asChange(final T state);
}
