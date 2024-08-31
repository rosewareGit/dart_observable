abstract interface class ChangeEmitter<T, C> {
  C asChange(final T state);

  C lastChange(final T state);
}
