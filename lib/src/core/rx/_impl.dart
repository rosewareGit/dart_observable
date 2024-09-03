import '../../../dart_observable.dart';

class RxImpl<T> extends RxBase<T> implements Rx<T> {
  RxImpl(
    super.value, {
    super.distinct = true,
  });
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
