import '../../../../dart_observable.dart';
import '../../../core/rx/num/rx_double.dart';

abstract class RxDouble implements Rx<double> {
  factory RxDouble(
    final double value, {
    final bool distinct = true,
  }) {
    return RxDoubleImpl(
      value,
      distinct: distinct,
    );
  }

  operator *(final double other);

  operator +(final double other);

  operator -(final double other);

  operator /(final double other);
}
