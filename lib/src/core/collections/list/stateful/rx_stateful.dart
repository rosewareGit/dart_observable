import '../../../../../dart_observable.dart';
import '../../_base.dart';
import '../list_state.dart';
import '../rx_actions.dart';
import '../rx_impl.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/map_item.dart';
import 'operators/rx_item.dart';
import 'state.dart';

class RxStatefulListImpl<E, S>
    extends RxCollectionBase<Either<ObservableListChange<E>, S>, ObservableStatefulListState<E, S>>
    with RxListActionsImpl<E>
    implements RxStatefulList<E, S> {
  final FactoryList<E> _factory;

  RxStatefulListImpl(
    final List<E> data, {
    required final FactoryList<E>? factory,
  }) : this._(
          () {
            final FactoryList<E> $factory = factory ?? defaultListFactory<E>();
            final List<E> updatedList = $factory(data);
            return RxStatefulListState<E, S>.fromState(RxListState<E>(updatedList, ObservableListChange<E>()));
          }(),
          factory: factory,
        );

  factory RxStatefulListImpl.custom(
    final S state, {
    final FactoryList<E>? factory,
  }) {
    return RxStatefulListImpl<E, S>._(
      RxStatefulListState<E, S>.custom(state),
      factory: factory,
    );
  }

  RxStatefulListImpl._(
    final ObservableStatefulListState<E, S> state, {
    final FactoryList<E>? factory,
  })  : _factory = factory ?? defaultListFactory<E>(),
        super(state);

  @override
  List<E> get data => value.fold(
        onData: (final ObservableListState<E> data) => data.listView,
        onCustom: (final _) => _factory(<E>[]),
      );

  @override
  int? get length => value.fold(
        onData: (final ObservableListState<E> data) => data.listView.length,
        onCustom: (final S state) => null,
      );

  @override
  E? operator [](final int position) {
    return value.fold(
      onData: (final ObservableListState<E> data) {
        final List<E> currentData = data.listView;
        if (position < 0 || position >= currentData.length) {
          return null;
        }
        return currentData[position];
      },
      onCustom: (final _) => null,
    );
  }

  @override
  Either<ObservableListChange<E>, S>? applyAction(
    final Either<ObservableListUpdateAction<E>, S> action,
  ) {
    final ObservableStatefulListState<E, S> currentValue = value;
    return action.fold<Either<ObservableListChange<E>, S>?>(
      onLeft: (final ObservableListUpdateAction<E> listUpdateAction) {
        return currentValue.fold(
          onData: (final ObservableListState<E> data) {
            final RxListState<E> state = data as RxListState<E>;
            final List<E> updatedList = state.data;
            final ObservableListChange<E> change = listUpdateAction.apply(updatedList);

            if (change.isEmpty) {
              return null;
            }

            final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.fromState(
              RxListState<E>(updatedList, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
          onCustom: (final S state) {
            final List<E> updatedList = _factory(<E>[]);
            final ObservableListChange<E> change = listUpdateAction.apply(updatedList);

            final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.fromState(
              RxListState<E>(updatedList, change),
            );

            super.value = newState;
            return newState.lastChange;
          },
        );
      },
      onRight: (final S action) {
        final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.custom(action);
        super.value = newState;
        return newState.lastChange;
      },
    );
  }

  @override
  ObservableListChange<E>? applyListUpdateAction(final ObservableListUpdateAction<E> action) {
    return applyAction(
      Either<ObservableListUpdateAction<E>, S>.left(action),
    )?.leftOrNull;
  }

  @override
  ObservableStatefulList<E, S> changeFactory(final FactoryList<E> factory) {
    return OperatorStatefulListChangeFactory<E, S>(
      source: this,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E, S> filterItem(
    final bool Function(E item) predicate, {
    final FactoryList<E>? factory,
  }) {
    return StatefulListFilterOperator<E, S>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableStatefulList<E2, S> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactoryList<E2>? factory,
  }) {
    return OperatorStatefulListMapItem<E, E2, S>(
      source: this,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  void onEmptyData() {
    final List<E> updatedList = _factory(<E>[]);
    final RxStatefulListState<E, S> newState = RxStatefulListState<E, S>.fromState(
      RxListState<E>(updatedList, ObservableListChange<E>()),
    );

    super.value = newState;
  }

  @override
  Observable<Either<E?, S>> rxItem(final int position) {
    return OperatorObservableListStatefulRxItem<E, S>(
      source: this,
      position: position,
    );
  }

  @override
  Either<ObservableListChange<E>, S>? setState(final S newState) {
    return applyAction(Either<ObservableListUpdateAction<E>, S>.right(newState));
  }
}
