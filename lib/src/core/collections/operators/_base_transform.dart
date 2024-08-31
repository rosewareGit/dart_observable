import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../../rx/base_tracking.dart';
import '_base_transform_proxy.dart';

mixin BaseCollectionTransformOperator<
    Self extends ChangeTrackingObservable<Self, CS, C>,
    Current extends ChangeTrackingObservable<Current, CS2, C2>,
    CS, // Collection state for this
    CS2, // Collection state for the transformed
    C,
    C2,
    U> on RxBaseTracking<Current, CS2, C2> {
  late final BaseCollectionTransformOperatorProxy<Self, CS, CS2, C, C2> proxy =
      BaseCollectionTransformOperatorProxy<Self, CS, CS2, C, C2>(
    current: this,
    source: source,
    transformChange: (final C change) {
      transformChange(change, applyAction);
    },
  );

  Self get source;

  C2? applyAction(final U action);

  @override
  void onInit() {
    proxy.init();
    super.onInit();
  }

  void transformChange(
    final C change,
    final Emitter<U> updater,
  );
}
