abstract class CollectionState<C> {
  C get lastChange;

  C asChange();
}
