import '../../../dart_observable.dart';
import 'operators/flatmaps.dart';
import 'operators/transforms.dart';

mixin ObservableCollectionBase<Self extends ObservableCollection<C, CS>, C, CS extends CollectionState<C>>
    implements ObservableCollection<C, CS> {
  @override
  ObservableFlatMaps<C> get flatMapChangeAs {
    return ObservableCollectionFlatMapsImpl<Self, CS, C>(self);
  }

  Self get self;

  @override
  ObservableTransforms<C> get transformChangeAs => ObservableTransformsImpl<CS, C>(self);
}
