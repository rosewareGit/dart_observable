import 'dart:collection';

import '../../../../../dart_observable.dart';
import '../../_base_stateful.dart';
import '../rx_actions.dart';
import '../rx_impl.dart';
import 'operators/change_factory.dart';
import 'operators/filter_item.dart';
import 'operators/filter_item_state.dart';
import 'operators/map_item.dart';
import 'operators/map_item_state.dart';
import 'operators/rx_item.dart';

class RxStatefulSetImpl<E, S> extends RxCollectionStatefulBase<Set<E>, ObservableSetChange<E>, S>
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
            return Either<Set<E>, S>.left(updatedSet);
          }(),
          factory: factory,
        );

  factory RxStatefulSetImpl.custom(
    final S state, {
    final FactorySet<E>? factory,
  }) {
    return RxStatefulSetImpl<E, S>._(
      Either<Set<E>, S>.right(state),
      factory: factory,
    );
  }

  RxStatefulSetImpl._(
    final Either<Set<E>, S> state, {
    final FactorySet<E>? factory,
  })  : _factory = factory ?? defaultSetFactory<E>(),
        super(state) {
    _change = currentStateAsChange;
  }

  @override
  Either<ObservableSetChange<E>, S> get change => _change;

  @override
  Either<ObservableSetChange<E>, S> get currentStateAsChange {
    return _value.fold(
      onLeft: (final Set<E> data) {
        final ObservableSetChange<E> change = ObservableSetChange<E>(added: data);
        return Either<ObservableSetChange<E>, S>.left(change);
      },
      onRight: (final S state) {
        return Either<ObservableSetChange<E>, S>.right(state);
      },
    );
  }

  @override
  Set<E> get data => _value.fold(
        onLeft: (final Set<E> data) => data,
        onRight: (final _) => _factory(<E>{}),
      );

  @override
  int? get length => _value.fold(
        onLeft: (final Set<E> data) => data.length,
        onRight: (final S state) => null,
      );

  @override
  Either<UnmodifiableSetView<E>, S> get value {
    return _value.fold(
      onLeft: (final Set<E> data) => Either<UnmodifiableSetView<E>, S>.left(UnmodifiableSetView<E>(data)),
      onRight: (final S state) => Either<UnmodifiableSetView<E>, S>.right(state),
    );
  }

  Either<Set<E>, S> get _value => super.value;

  @override
  Either<ObservableSetChange<E>, S>? applyAction(
    final Either<ObservableSetUpdateAction<E>, S> action,
  ) {
    return action.fold<Either<ObservableSetChange<E>, S>?>(
      onLeft: (final ObservableSetUpdateAction<E> updateAction) {
        return _value.fold(
          onLeft: (final Set<E> data) {
            final ObservableSetChange<E> setChange = updateAction.apply(data);

            if (setChange.isEmpty) {
              return null;
            }

            final Either<ObservableSetChange<E>, S> change = Either<ObservableSetChange<E>, S>.left(setChange);
            _change = change;
            notify();
            return change;
          },
          onRight: (final S state) {
            final Set<E> updatedSet = _factory(<E>[]);
            final ObservableSetChange<E> setChange = updateAction.apply(updatedSet);

            final Either<ObservableSetChange<E>, S> change = Either<ObservableSetChange<E>, S>.left(setChange);

            _change = change;
            _setData(updatedSet);
            return change;
          },
        );
      },
      onRight: (final S action) {
        _change = Either<ObservableSetChange<E>, S>.right(action);
        _setCustom(action);
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
      onLeft: (final Set<E> data) => data.contains(item),
      onRight: (final _) => false,
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

  void _setCustom(final S custom) {
    super.value = Either<Set<E>, S>.right(custom);
  }

  void _setData(final Set<E> data) {
    super.value = Either<Set<E>, S>.left(data);
  }
}
