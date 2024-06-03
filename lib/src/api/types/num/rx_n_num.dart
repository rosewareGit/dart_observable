import '../../../../../dart_observable.dart';
import '../../../core/rx/num/rx_n_num.dart';

abstract class RxnNum implements Rxn<num> {
  factory RxnNum({
    final num? value,
    final bool distinct = true,
  }) {
    return RxnNumImpl(
      value: value,
      distinct: distinct,
    );
  }

  operator *(final num other);

  operator +(final num other);

  operator -(final num other);

  operator /(final num other);
}
