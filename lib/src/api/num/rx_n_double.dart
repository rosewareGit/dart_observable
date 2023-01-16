import '../../core/rx/num/rx_n_double.dart';
import '../rx.dart';

abstract class RxnDouble implements Rxn<double> {
  factory RxnDouble({
    final double? value,
    final bool distinct = true,
  }) {
    return RxnDoubleImpl(
      value: value,
      distinct: distinct,
    );
  }

  operator *(final double other);

  operator +(final double other);

  operator -(final double other);

  operator /(final double other);
}
