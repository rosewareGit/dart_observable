abstract class CollectionState<E, C> {
  C asChange();

  C get lastChange;
}
