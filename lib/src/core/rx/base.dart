import '../../api/change_tracking_observable.dart';
import 'base_tracking.dart';

abstract class RxBase<S extends ChangeTrackingObservable<S, T, T>, T> extends RxBaseTracking<S, T, T> {
  RxBase(
    super.value, {
    final bool distinct = true,
  }) : super(
          distinct: distinct,
        );

  @override
  T asChange(final T state) => state;

  @override
  T lastChange(final T state) => state;
}
