import '../../../../../../dart_observable.dart';
import '../../list_state.dart';
import '../../rx_impl.dart';
import '../operators/map_item.dart';
import '../rx_stateful.dart';
import '../state.dart';

class RxListUndefinedImpl<E> extends RxListStatefulImpl<RxListUndefined<E>, ObservableListUndefined<E>, E, Undefined>
    implements RxListUndefined<E> {
  RxListUndefinedImpl({
    final Iterable<E>? initial,
    final FactoryList<E>? factory,
  }) : this._(
          state: () {
            if (initial == null) {
              RxListStatefulState<E, Undefined>.custom(Undefined());
            }
            final FactoryList<E> $factory = factory ?? defaultListFactory();
            final List<E> list = $factory(initial);
            return RxListStatefulState<E, Undefined>.data(RxListState<E>.initial(list));
          }(),
          factory: factory,
        );

  factory RxListUndefinedImpl.undefined({
    final FactoryList<E>? factory,
  }) {
    return RxListUndefinedImpl<E>._(
      state: RxListStatefulState<E, Undefined>.custom(Undefined()),
      factory: factory,
    );
  }

  RxListUndefinedImpl._({
    required final ObservableListStatefulState<E, Undefined> state,
    final FactoryList<E>? factory,
  }) : super(state, factory: factory);

  @override
  ObservableListUndefined<E> get self => this;

  @override
  RxListUndefined<E> builder({
    final List<E>? items,
    final FactoryList<E>? factory,
  }) {
    return RxListUndefined<E>(initial: items, factory: factory);
  }

  @override
  ObservableListUndefined<E2> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  }) {
    final RxListUndefined<E2> instance = RxListUndefinedImpl<E2>(factory: factory);
    OperatorStatefulListMapItem<RxListUndefined<E2>, ObservableListUndefined<E2>, ObservableListUndefined<E>, E, E2,
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
