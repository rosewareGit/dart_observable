import '../../../../../../dart_observable.dart';
import '../../rx_impl.dart';
import '../../set_state.dart';
import '../operators/map_item.dart';
import '../rx_stateful_impl.dart';
import '../state.dart';

class RxSetUndefinedImpl<E> extends RxSetStatefulImpl<RxSetUndefined<E>, ObservableSetUndefined<E>, E, Undefined>
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

  @override
  RxSetUndefined<E> builder({
    final Iterable<E>? items,
    final FactorySet<E>? factory,
  }) {
    return RxSetUndefinedImpl<E>(
      initial: items,
      factory: factory,
    );
  }

  @override
  ObservableSetUndefined<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  }) {
    final RxSetUndefined<E2> instance = RxSetUndefined<E2>(factory: factory);
    OperatorStatefulSetMapItem<RxSetUndefined<E2>, ObservableSetUndefined<E2>, ObservableSetUndefined<E>, E, E2,
        Undefined>(
      source: self,
      mapper: mapper,
      instanceBuilder: () => instance,
    );
    return instance.asObservable();
  }

  @override
  void setUndefined() {
    setState(Undefined());
  }
}
