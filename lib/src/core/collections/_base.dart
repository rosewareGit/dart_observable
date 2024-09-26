import '../../../dart_observable.dart';
import '../../api/collections/collection_transforms.dart';
import 'operators/switch_maps.dart';
import 'operators/transforms.dart';

abstract class RxCollectionBase<C, CS extends CollectionState<C>> extends RxBase<CS>
    implements ObservableCollection<C, CS> {

  RxCollectionBase(super.value, {super.distinct});

  @override
  ObservableCollectionTransforms<C> get transformChangeAs => ObservableCollectionTransformsImpl<CS, C>(this);

  @override
  ObservableCollectionSwitchMaps<C> get switchMapChangeAs => ObservableCollectionFlatMapsImpl<CS, C>(this);
}
