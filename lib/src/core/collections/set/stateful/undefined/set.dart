import '../../../../../../dart_observable.dart';
import '../../set.dart';
import '../../set_state.dart';
import '../set.dart';
import '../state.dart';

class RxSetUndefinedImpl<E> extends RxSetStatefulImpl<ObservableSetUndefined<E>, E, Undefined>
    implements RxSetUndefined<E> {
  RxSetUndefinedImpl({
    final Iterable<E>? initial,
    final FactorySet<E>? factory,
  }) : this._(
          state: () {
            if (initial == null) {
              RxSetStatefulState<E, Undefined>.custom(Undefined());
            }
            final FactorySet<E> $factory = factory ?? defaultSetFactory();
            final Set<E> set = $factory(initial);
            return RxSetStatefulState<E, Undefined>.data(RxSetState<E>.initial(set));
          }(),
          factory: factory,
        );

  factory RxSetUndefinedImpl.undefined({
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedImpl<E>._(
      state: RxSetStatefulState<E, Undefined>.custom(Undefined()),
      factory: factory,
    );
  }

  RxSetUndefinedImpl._({
    required final ObservableSetStatefulState<E, Undefined> state,
    final FactorySet<E>? factory,
  }) : super(state, factory: factory);

  @override
  ObservableSetUndefined<E> get self => this;
}
