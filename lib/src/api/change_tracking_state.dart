abstract class ChangeTrackingState<C> {
  C get lastChange;

  C asChange();
}
