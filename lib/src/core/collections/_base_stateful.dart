import '../../../dart_observable.dart';
import '_base.dart';

abstract class RxCollectionStatefulBase<T, CS extends ObservableCollectionState<T, S>, C, S>
    extends RxCollectionBase<CS, Either<C, S>> implements ObservableCollectionStateful<C, S, CS> {
  CS? _previous;

  RxCollectionStatefulBase(super.value, {super.distinct});

  @override
  CS? get previous {
    final CS? previous = _previous;
    final CS current = value;
    if (previous == null) {
      return null;
    }

    // When the previous state is different from the current state, return the previous state
    // Otherwise, return null
    return previous == current ? null : previous;
  }

  @override
  set value(final CS value) {
    _previous = super.value;
    super.value = value;
  }
}
