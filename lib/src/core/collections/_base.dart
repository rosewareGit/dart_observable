import '../../../dart_observable.dart';

mixin ObservableCollectionBase<Self extends ObservableCollection<Self, E, C, CS>, E, C,
    CS extends ChangeTrackingState<C>> implements ObservableCollection<Self, E, C, CS> {
  Self get self;

  @override
  C asChange(final CS state) => state.asChange();

  @override
  C lastChange(final CS state) => state.lastChange;
//
// @override
// ObservableMapResult<K2, V2, F> transformCollectionAsMapResult<K2, V2, F>({
//   required final void Function(
//     ObservableMapResult<K2, V2, F> state,
//     C change,
//     Emitter<ObservableMapResultUpdateAction<K2, V2, F>> updater,
//   ) transform,
//   final FactoryMap<K2, V2>? factory,
// }) {
//   return OperatorCollectionsTransformAsMapResult<E, C, CS, K2, V2, F>(
//     source: this,
//     transformFn: transform,
//     factory: factory,
//   );
// }
//
// @override
// ObservableSetResult<E2, F> transformCollectionAsSetResult<E2, F>({
//   required final void Function(
//     ObservableSetResult<E2, F> state,
//     C change,
//     Emitter<ObservableSetResultUpdateAction<E2, F>> updater,
//   ) transform,
//   final Set<E2> Function(Iterable<E2>? items)? factory,
// }) {
//   return OperatorCollectionsTransformAsSetResult<E, E2, F, C, CS>(
//     source: this,
//     transformFn: transform,
//     factory: factory,
//   );
// }
}
