import '../../../../dart_observable.dart';
import '../_impl.dart';

class RxnDoubleImpl extends RxnImpl<double> implements RxnDouble {
  RxnDoubleImpl({
    super.value,
    super.distinct,
  });

  @override
  operator *(final double other) {
    final double? $value = value;
    if ($value == null) {
      return;
    }

    value = $value * other;
  }

  @override
  operator +(final double other) {
    final double? $value = value;

    if ($value == null) {
      value = other;
      return;
    }

    value = $value + other;
  }

  @override
  operator -(final double other) {
    final double? $value = value;

    if ($value == null) {
      value = -other;
      return;
    }

    value = $value - other;
  }

  @override
  operator /(final double other) {
    final double? $value = value;

    if ($value == null) {
      return;
    }

    value = $value / other;
  }
}
