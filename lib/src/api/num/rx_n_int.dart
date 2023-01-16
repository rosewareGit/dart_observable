import '../../../dart_observable.dart';
import '../../core/rx/num/rx_n_int.dart';

abstract class RxnInt implements Rxn<int> {
  factory RxnInt({
    final int? value,
    final bool distinct = true,
  }) {
    return RxnIntImpl(
      value: value,
      distinct: distinct,
    );
  }

  operator *(final int other);

  operator +(final int other);

  operator -(final int other);

  operator /(final int other);
}
