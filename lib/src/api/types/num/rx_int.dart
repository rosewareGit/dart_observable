import '../../../../dart_observable.dart';
import '../../../core/rx/num/rx_int.dart';

abstract class RxInt implements Rx<int> {
  factory RxInt(
    final int value, {
    final bool distinct = true,
  }) {
    return RxIntImpl(
      value,
      distinct: distinct,
    );
  }

  operator *(final int other);

  operator +(final int other);

  operator -(final int other);

  operator /(final int other);
}
