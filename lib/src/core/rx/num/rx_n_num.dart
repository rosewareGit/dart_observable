import '../../../../../dart_observable.dart';
import '../_impl.dart';

class RxnNumImpl extends RxnImpl<num> implements RxnNum {
  RxnNumImpl({
    super.value,
    super.distinct,
  });

  @override
  operator *(final num other) {
    final num? $value = value;

    if ($value == null) {
      return;
    }

    value = $value * other;
  }

  @override
  operator +(final num other) {
    final num? $value = value;

    if ($value == null) {
      value = other;
      return;
    }

    value = $value + other;
  }

  @override
  operator -(final num other) {
    final num? $value = value;

    if ($value == null) {
      value = -other;
      return;
    }

    value = $value - other;
  }

  @override
  operator /(final num other) {
    final num? $value = value;

    if ($value == null) {
      return;
    }

    value = $value / other;
  }
}
