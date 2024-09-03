import '../../../../dart_observable.dart';
import '_base_transform_proxy.dart';

mixin BaseTransformOperator<
    T, // Collection state for this
    T2, // Collection state for the transformed
    U> on RxBase<T2> {
  late final BaseTransformOperatorProxy<T, T2> proxy = BaseTransformOperatorProxy<T, T2>(
    current: this,
    source: source,
    transform: (final T update) {
      transformChange(update, handleUpdate);
    },
  );

  Observable<T> get source;

  void handleUpdate(final U action);

  @override
  void onInit() {
    proxy.init();
    super.onInit();
  }

  void transformChange(
    final T value,
    final Emitter<U> updater,
  );
}
