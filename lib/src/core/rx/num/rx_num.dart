import '../../../../dart_observable.dart';
import '../_impl.dart';

class RxNumImpl extends RxImpl<num> implements RxNum {
  RxNumImpl(
    super.value, {
    super.distinct,
  });

  @override
  operator *(final num other) {
    value *= other;
  }

  @override
  operator +(final num other) {
    value += other;
  }

  @override
  operator -(final num other) {
    value -= other;
  }

  @override
  operator /(final num other) {
    value /= other;
  }
}
