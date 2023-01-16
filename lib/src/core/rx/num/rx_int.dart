import '../../../../dart_observable.dart';
import '../_impl.dart';

class RxIntImpl extends RxImpl<int> implements RxInt {
  RxIntImpl(
    super.value, {
    super.distinct,
  });

  @override
  operator *(final int other) {
    value *= other;
  }

  @override
  operator +(final int other) {
    value += other;
  }

  @override
  operator -(final int other) {
    value -= other;
  }

  @override
  operator /(final int other) {
    value ~/= other;
  }
}
