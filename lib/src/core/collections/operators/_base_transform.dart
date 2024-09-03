import '../../../../dart_observable.dart';
import '_base_transform_proxy.dart';

mixin BaseCollectionTransformOperator<
    CR extends CollectionState<C>, // Collection state for this
    CR2 extends CollectionState<C2>, // Collection state for the transformed
    C,
    C2,
    U> on RxBase<CR2> {
  late final BaseCollectionTransformOperatorProxy<CR, CR2, C, C2> proxy =
      BaseCollectionTransformOperatorProxy<CR, CR2, C, C2>(
    current: this,
    source: source,
    transformChange: (final C change) {
      transformChange(change, applyAction);
    },
  );

  Observable<CR> get source;

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
