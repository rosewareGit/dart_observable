import '../../../../dart_observable.dart';
import '../_impl.dart';

class RxDoubleImpl extends RxImpl<double> implements RxDouble {
  RxDoubleImpl(
    super.value, {
    super.distinct,
  });

  @override
  operator *(final double other) {
    value *= other;
  }

  @override
  operator +(final double other) {
    value += other;
  }

  @override
  operator -(final double other) {
    value -= other;
  }

  @override
  operator /(final double other) {
    value /= other;
  }
}
