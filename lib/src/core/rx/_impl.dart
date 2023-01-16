import '../../../dart_observable.dart';

class RxImpl<T> extends RxBase<T> implements Rx<T> {
  RxImpl(
    final T value, {
    super.distinct = true,
  }) : super(
          value: value,
        );
}

class RxnImpl<T> extends RxImpl<T?> implements Rxn<T> {
  RxnImpl({
    final T? value,
    final bool distinct = true,
  }) : super(
          value,
          distinct: distinct,
        );
}
