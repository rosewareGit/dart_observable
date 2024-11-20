import 'dart:collection';

import '../../../../../dart_observable.dart';
import '../../_base_stateful.dart';
import '../rx_actions.dart';
import '../rx_impl.dart';
import '../set_state.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/filter_item_state.dart';
import 'operators/map_item.dart';
import 'operators/map_item_state.dart';
import 'operators/rx_item.dart';
import 'state.dart';

class RxStatefulSetImpl<E, S>
    extends RxCollectionStatefulBase<ObservableSetState<E>, ObservableStatefulSetState<E, S>, ObservableSetChange<E>, S>
    with RxSetActionsImpl<E>
    implements RxStatefulSet<E, S> {
  final FactorySet<E> _factory;
  late Either<ObservableSetChange<E>, S> _change;

  RxStatefulSetImpl(
    final Iterable<E> data, {
    final FactorySet<E>? factory,
  }) : this._(
          () {
            final FactorySet<E> $factory = factory ?? defaultSetFactory<E>();
            final Set<E> updatedSet = $factory(data);
            return RxStatefulSetState<E, S>.fromSet(updatedSet);
          }(),
          factory: factory,
        );

  factory RxStatefulSetImpl.custom(
    final S state, {
    final FactorySet<E>? factory,
  }) {
    return RxStatefulSetImpl<E, S>._(
      RxStatefulSetState<E, S>.custom(state),
      factory: factory,
    );
  }

  RxStatefulSetImpl._(
    final ObservableStatefulSetState<E, S> state, {
    final FactorySet<E>? factory,
  })  : _factory = factory ?? defaultSetFactory<E>(),
        super(state) {
    _change = currentStateAsChange;
  }

  @override
  Either<ObservableSetChange<E>, S> get change => _change;

  @override
  Either<ObservableSetChange<E>, S> get currentStateAsChange {
    return value.fold(
      onData: (final ObservableSetState<E> data) {
        final ObservableSetChange<E> change = ObservableSetChange<E>(
          added: data.setView,
        );
        return Either<ObservableSetChange<E>, S>.left(change);
      },
      onCustom: (final S state) {
        return Either<ObservableSetChange<E>, S>.right(state);
      },
    );
  }

  @override
  Set<E> get data => value.fold(
        onData: (final ObservableSetState<E> data) => data.setView,
        onCustom: (final _) => _factory(<E>{}),
      );

  @override
  int? get length => value.fold(
        onData: (final ObservableSetState<E> data) => data.setView.length,
        onCustom: (final S state) => null,
      );

  @override
  Either<ObservableSetChange<E>, S>? applyAction(
    final Either<ObservableSetUpdateAction<E>, S> action,
  ) {
    final ObservableStatefulSetState<E, S> currentValue = value;
    return action.fold<Either<ObservableSetChange<E>, S>?>(
      onLeft: (final ObservableSetUpdateAction<E> updateAction) {
        return currentValue.fold(
          onData: (final ObservableSetState<E> data) {
            final RxSetState<E> state = data as RxSetState<E>;
            final Set<E> updatedSet = state.data;
            final ObservableSetChange<E> setChange = updateAction.apply(updatedSet);

            if (setChange.isEmpty) {
              return null;
            }

            final Either<ObservableSetChange<E>, S> change = Either<ObservableSetChange<E>, S>.left(setChange);
            _change = change;
            notify();
            return change;
          },
          onCustom: (final S state) {
            final Set<E> updatedSet = _factory(<E>[]);
            final ObservableSetChange<E> setChange = updateAction.apply(updatedSet);

            final RxStatefulSetState<E, S> newState = RxStatefulSetState<E, S>.fromState(
              RxSetState<E>(updatedSet),
            );

            final Either<ObservableSetChange<E>, S> change = Either<ObservableSetChange<E>, S>.left(setChange);

            _change = change;
            super.value = newState;
            return change;
          },
        );
      },
      onRight: (final S action) {
        final RxStatefulSetState<E, S> newState = RxStatefulSetState<E, S>.custom(action);
        _change = Either<ObservableSetChange<E>, S>.right(action);
        super.value = newState;
        return _change;
      },
    );
  }

  @override
  ObservableSetChange<E>? applySetUpdateAction(final ObservableSetUpdateAction<E> action) {
    return applyAction(
      Either<ObservableSetUpdateAction<E>, S>.left(action),
    )?.leftOrNull;
  }

  @override
  ObservableStatefulSet<E, S> changeFactory(final FactorySet<E> factory) {
    return OperatorStatefulSetChangeFactory<E, S>(
      source: this,
      factory: factory,
    );
  }

  @override
  bool contains(final E item) {
    return value.fold(
      onData: (final ObservableSetState<E> data) => data.setView.contains(item),
      onCustom: (final _) => false,
    );
  }

  @override
  ObservableStatefulSet<E, S> filterItem(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  }) {
    return OperatorStatefulSetFilterItem<E, S>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E, S> filterItemWithState(
    final bool Function(Either<E, S> item) predicate, {
    final FactorySet<E>? factory,
  }) {
    return OperatorStatefulSetFilterItemState<E, S>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E2, S> mapItem<E2>(
    final E2 Function(E item) mapper, {
    final FactorySet<E2>? factory,
  }) {
    return OperatorStatefulSetMapItem<E, E2, S>(
      source: this,
      mapper: mapper,
      factory: factory,
    );
  }

  @override
  ObservableStatefulSet<E2, S2> mapItemWithState<E2, S2>({
    required final E2 Function(E item) mapper,
    required final S2 Function(S state) stateMapper,
    final FactorySet<E2>? factory,
  }) {
    return OperatorStatefulSetMapItemWithState<E, E2, S, S2>(
      source: this,
      mapper: mapper,
      stateMapper: stateMapper,
      factory: factory,
    );
  }

  @override
  Observable<Either<E?, S>> rxItem(final bool Function(E item) predicate) {
    return OperatorObservableSetStatefulRxItem<E, S>(
      source: this,
      predicate: predicate,
    );
  }

  @override
  Either<ObservableSetChange<E>, S>? setState(final S newState) {
    return applyAction(Either<ObservableSetUpdateAction<E>, S>.right(newState));
  }

  @override
  ObservableStatefulSet<E, S> sorted(final Comparator<E> compare) {
    return changeFactory((final Iterable<E>? initial) => SplayTreeSet<E>.of(initial ?? <E>{}, compare));
  }
}
