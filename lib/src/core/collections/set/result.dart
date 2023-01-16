import 'dart:collection';

import 'package:collection/collection.dart';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import 'operators/result_rx_item.dart';
import 'operators/result_rx_item_by_pos.dart';

part 'result_state.dart';

Set<E> Function(Iterable<E>? items) _defaultSetFactory<E>() {
  return (final Iterable<E>? items) {
    return items?.toSet() ?? <E>{};
  };
}

ObservableSetResultState<E, F> _initialState<E, F>({
  required final Iterable<E>? initial,
  required final Set<E> Function(Iterable<E>? items) factory,
}) {
  if (initial == null) {
    return ObservableSetResultState<E, F>.undefined(removedItems: <E>{});
  }

  return ObservableSetResultState<E, F>.data(
    data: factory(initial),
    change: ObservableSetChange<E>(added: initial.toSet()),
  );
}

Set<E> Function(Iterable<E>? items) _splayTreeSetFactory<E>(final Comparator<E> compare) {
  return (final Iterable<E>? items) {
    return SplayTreeSet<E>.from(items ?? <E>{}, compare);
  };
}

class RxSetResultImpl<E, F> extends RxImpl<ObservableSetResultState<E, F>>
    with ObservableCollectionBase<E, ObservableSetResultChange<E, F>, ObservableSetResultState<E, F>>
    implements RxSetResult<E, F> {
  final Set<E> Function(Iterable<E>? items) _factory;

  RxSetResultImpl({
    final Set<E> Function(Iterable<E>? items)? factory,
  })  : _factory = factory ?? _defaultSetFactory(),
        super(
          ObservableSetResultState<E, F>.undefined(removedItems: <E>{}),
        );

  factory RxSetResultImpl.custom({
    final Set<E> Function(Iterable<E>? items)? factory,
    final Iterable<E>? initial,
  }) {
    final Set<E> Function(Iterable<E>? items) $factory = factory ?? _defaultSetFactory();
    return RxSetResultImpl<E, F>._(
      state: _initialState<E, F>(
        initial: initial,
        factory: $factory,
      ),
      factory: $factory,
    );
  }

  factory RxSetResultImpl.failure({
    required final F failure,
    final Set<E> Function(Iterable<E>? items)? factory,
  }) {
    final Set<E> Function(Iterable<E>? items) $factory = factory ?? _defaultSetFactory();
    return RxSetResultImpl<E, F>._(
      state: ObservableSetResultState<E, F>.failure(failure, removedItems: <E>{}),
      factory: $factory,
    );
  }

  factory RxSetResultImpl.splayTreeSet({
    required final Comparator<E> compare,
    final Iterable<E>? initial,
  }) {
    return RxSetResultImpl<E, F>._(
      state: _initialState<E, F>(
        initial: initial,
        factory: _splayTreeSetFactory<E>(compare),
      ),
      factory: _splayTreeSetFactory<E>(compare),
    );
  }

  RxSetResultImpl.state({
    required final ObservableSetResultState<E, F> state,
    final Set<E> Function(Iterable<E>? items)? factory,
  })  : _factory = factory ?? _defaultSetFactory(),
        super(state);

  RxSetResultImpl._({
    required final ObservableSetResultState<E, F> state,
    required final Set<E> Function(Iterable<E>? items) factory,
  })  : _factory = factory,
        super(state);

  @override
  set data(final Set<E> data) {
    this.value = ObservableSetResultState<E, F>.data(
      data: data,
      change: ObservableSetChange<E>(added: data),
    );
  }

  @override
  set failure(final F failure) {
    applyAction(
      ObservableSetResultUpdateActionFailure<E, F>(
        failure: failure,
      ),
    );
  }

  @override
  set value(final ObservableSetResultState<E, F> newState) {
    newState.when(
      onUndefined: () {
        applyAction(
          ObservableSetResultUpdateActionUndefined<E, F>(),
        );
      },
      onFailure: (final F failure) {
        applyAction(
          ObservableSetResultUpdateActionFailure<E, F>(failure: failure),
        );
      },
      onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
        value.when(
          onUndefined: () {
            applyAction(
              ObservableSetResultUpdateActionData<E, F>(removeItems: change.removed, addItems: change.added),
            );
          },
          onFailure: (final F failure) {
            applyAction(
              ObservableSetResultUpdateActionData<E, F>(removeItems: change.removed, addItems: change.added),
            );
          },
          onSuccess: (final UnmodifiableSetView<E> previousData, final ObservableSetChange<E> currentChange) {
            final ObservableSetChange<E> change = ObservableSetChange<E>.fromDiff(previousData, data);
            if (change.isEmpty) {
              return;
            }
            super.value = ObservableSetResultState<E, F>.data(data: _factory(data), change: change);
          },
        );
      },
    );
  }

  @override
  void add(final E item) {
    applyAction(
      ObservableSetResultUpdateActionData<E, F>(
        addItems: <E>{item},
        removeItems: <E>{},
      ),
    );
  }

  @override
  void addAll(final Iterable<E> items) {
    applyAction(
      ObservableSetResultUpdateActionData<E, F>(
        addItems: items.toSet(),
        removeItems: <E>{},
      ),
    );
  }

  @override
  void applyAction(final ObservableSetResultUpdateAction<E, F> action) {
    switch (action) {
      case ObservableSetResultUpdateActionUndefined<E, F> _:
        value.when(
          onUndefined: () {
            // Same state, nothing to  do
          },
          onFailure: (final F failure) {
            super.value = ObservableSetResultState<E, F>.undefined(removedItems: <E>{});
          },
          onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
            super.value = ObservableSetResultState<E, F>.undefined(removedItems: data);
          },
        );
        break;
      case final ObservableSetResultUpdateActionFailure<E, F> failure:
        value.when(
          onUndefined: () {
            super.value = ObservableSetResultState<E, F>.failure(failure.failure, removedItems: <E>{});
          },
          onFailure: (final F currentFailure) {
            if (currentFailure != failure.failure) {
              super.value = ObservableSetResultState<E, F>.failure(failure.failure, removedItems: <E>{});
            }
          },
          onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
            super.value = ObservableSetResultState<E, F>.failure(failure.failure, removedItems: data);
          },
        );
        break;
      case final ObservableSetResultUpdateActionData<E, F> action:
        switch (value) {
          case final ObservableSetResultStateData<E, F> data:
            final Set<E> set = (data as RxSetResultStateData<E, F>)._data;
            final ObservableSetChange<E> change = action.apply(set);

            if (change.isEmpty) {
              return;
            }

            final ObservableSetResultState<E, F> newState = ObservableSetResultState<E, F>.data(
              data: set,
              change: change,
            );
            super.value = newState;
            break;
          case ObservableSetResultStateFailure<E, F>():
            super.value = ObservableSetResultState<E, F>.data(
              data: _factory(action.addItems),
              change: ObservableSetChange<E>(added: action.addItems),
            );
            break;
          case ObservableSetResultStateUndefined<E, F>():
            super.value = ObservableSetResultState<E, F>.data(
              data: _factory(action.addItems),
              change: ObservableSetChange<E>(added: action.addItems),
            );
            break;
        }
        break;
    }
  }

  @override
  ObservableSetResult<E, F> filterSetResult(
    final bool Function(E item) predicate, {
    final FactorySet<E>? factory,
  }) {
    return transformCollectionAsSetResult(
      transform: _filterTransform(predicate),
      factory: factory ?? _factory,
    );
  }

  @override
  void remove(final E item) {
    applyAction(
      ObservableSetResultUpdateActionData<E, F>(
        addItems: <E>{},
        removeItems: <E>{item},
      ),
    );
  }

  @override
  void removeWhere(final bool Function(E item) predicate) {
    final Set<E> itemsToRemove = <E>{};
    value.when(
      onUndefined: () {},
      onFailure: (final F failure) {},
      onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
        itemsToRemove.addAll(data.where(predicate));
      },
    );
    if (itemsToRemove.isEmpty) {
      return;
    }

    applyAction(
      ObservableSetResultUpdateActionData<E, F>(
        addItems: <E>{},
        removeItems: itemsToRemove,
      ),
    );
  }

  @override
  Observable<E?> rxItem(final bool Function(E item) predicate) {
    return OperatorObservableSetResultRxItem<E, F>(
      source: this,
      predicate: predicate,
    );
  }

  @override
  Observable<SnapshotResult<E?, F>> rxItemByIndex(final int index) {
    return OperatorObservableSetResultRxItemByPos<E, F>(
      source: this,
      index: index,
    );
  }

  @override
  void setUndefined() {
    applyAction(ObservableSetResultUpdateActionUndefined<E, F>());
  }

  void Function(
    ObservableSetResult<E, F> state,
    ObservableSetResultChange<E, F> change,
    Emitter<ObservableSetResultUpdateAction<E, F>> updater,
  ) _filterTransform(final bool Function(E item) predicate) {
    return (
      final ObservableSetResult<E, F> state,
      final ObservableSetResultChange<E, F> change,
      final Emitter<ObservableSetResultUpdateAction<E, F>> updater,
    ) {
      change.when(
        onUndefined: (final Set<E> removedItems) {
          updater(ObservableSetResultUpdateActionUndefined<E, F>());
        },
        onFailure: (final F failure, final Set<E> removedItems) {
          updater(ObservableSetResultUpdateActionFailure<E, F>(failure: failure));
        },
        onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
          final Set<E> added = change.added;
          final Set<E> removed = change.removed;

          updater(
            ObservableSetResultUpdateActionData<E, F>(
              addItems: added.where(predicate).toSet(),
              removeItems: removed,
            ),
          );
        },
      );
    };
  }
}
