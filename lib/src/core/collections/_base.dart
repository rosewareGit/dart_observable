import '../../../dart_observable.dart';

mixin ObservableCollectionBase<Self extends ObservableCollection<Self, C, CS>, C, CS extends ChangeTrackingState<C>>
    implements ObservableCollection<Self, C, CS> {
  Self get self;

  @override
  C asChange(final CS state) => state.asChange();

  @override
  C lastChange(final CS state) => state.lastChange;
}
