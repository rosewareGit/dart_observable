import '../../../../../../dart_observable.dart';
import '../../list.dart';
import '../../list_state.dart';
import '../list.dart';
import '../state.dart';

class RxListUndefinedImpl<E> extends RxListStatefulImpl<ObservableListUndefined<E>, E, Undefined>
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
}
