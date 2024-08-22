import '../../../../../../dart_observable.dart';
import '../../../../../core/collections/set/stateful/undefined/set.dart';

abstract class RxSetUndefined<E>
    implements ObservableSetUndefined<E>, RxSetStateful<ObservableSetUndefined<E>, E, Undefined> {
  factory RxSetUndefined({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedImpl<E>(
      initial: initial,
      factory: factory,
    );
  }
}
