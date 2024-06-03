import '../../../core/rx/num/rx_num.dart';
import '../../rx.dart';

abstract class RxNum implements Rx<num> {
  factory RxNum(
    final num value, {
    required final bool distinct,
  }) {
    return RxNumImpl(
      value,
      distinct: distinct,
    );
  }

  operator *(final num other);

  operator +(final num other);

  operator -(final num other);

  operator /(final num other);
}
