import '../../../../dart_observable.dart';
import '../_impl.dart';

class RxnIntImpl extends RxnImpl<int> implements RxnInt {
  RxnIntImpl({
    super.value,
    super.distinct,
  });

  @override
  operator *(final int other) {
    final int? $value = value;

    if ($value == null) {
      return;
    }

    value = $value * other;
  }

  @override
  operator +(final int other) {
    final int? $value = value;

    if ($value == null) {
      value = other;
      return;
    }

    value = $value + other;
  }

  @override
  operator -(final int other) {
    final int? $value = value;

    if ($value == null) {
      value = -other;
      return;
    }

    value = $value - other;
  }

  @override
  operator /(final int other) {
    final int? $value = value;

    if ($value == null) {
      return;
    }

    value = $value ~/ other;
  }
}
