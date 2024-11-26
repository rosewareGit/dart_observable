import '../../../dart_observable.dart';
import '_base.dart';

abstract class RxCollectionStatefulBase<T, C, S>
    extends RxCollectionBase<Either<T, S>, Either<C, S>> implements ObservableCollectionStateful<C, S, Either<T, S>> {
  Either<T, S>? _previous;

  RxCollectionStatefulBase(super.value, {super.distinct});

  @override
  Either<T, S>? get previous {
    final Either<T, S>? previous = _previous;
    final Either<T, S> current = value;
    if (previous == null) {
      return null;
    }

    // When the previous state is different from the current state, return the previous state
    // Otherwise, return null
    return previous == current ? null : previous;
  }

  @override
  set value(final Either<T, S> value) {
    _previous = super.value;
    super.value = value;
  }
}
