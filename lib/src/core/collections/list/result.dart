import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import 'operators/result_rx_item.dart';

part 'result_state.dart';

List<E> Function(Iterable<E>? items) _defaultListFactory<E>() {
  return (final Iterable<E>? items) {
    return List<E>.of(items ?? <E>{});
  };
}

ObservableListResultState<E, F> _initialState<E, F>({
  required final Iterable<E>? initial,
  required final List<E> Function(Iterable<E>? items) factory,
}) {
  if (initial == null) {
    return _MutableStateUndefined<E, F>(<E>[]);
  }

  final List<E> data = initial.toList();
  return _MutableStateData<E, F>(
    factory(data),
    ObservableListChange<E>(
      added: <int, E>{
        for (int i = 0; i < data.length; i++) i: data[i],
      },
    ),
  );
}

class RxListResultImpl<E, F> extends RxImpl<ObservableListResultState<E, F>>
    with ObservableCollectionBase<E, ObservableListResultChange<E, F>, ObservableListResultState<E, F>>
    implements RxListResult<E, F> {
  final List<E> Function(List<E>? items) _factory;

  RxListResultImpl({
    final List<E> Function(List<E>? items)? factory,
  })  : _factory = factory ?? _defaultListFactory<E>(),
        super(
          _MutableStateUndefined<E, F>(<E>[]),
        );

  factory RxListResultImpl.custom({
    final List<E> Function(Iterable<E>? items)? factory,
    final Iterable<E>? initial,
  }) {
    final List<E> Function(Iterable<E>? items) $factory = factory ?? _defaultListFactory();
    return RxListResultImpl<E, F>._(
      state: _initialState<E, F>(
        initial: initial,
        factory: $factory,
      ),
      factory: $factory,
    );
  }

  RxListResultImpl._({
    required final ObservableListResultState<E, F> state,
    required final List<E> Function(Iterable<E>? items) factory,
  })  : _factory = factory,
        super(state);

  @override
  E? operator [](final int position) {
    return value.when<E?>(
      onUndefined: () => null,
      onFailure: (final _) => null,
      onSuccess: (final UnmodifiableListView<E> data, final _) {
        if (position < 0 || position >= data.length) {
          return null;
        }
        return data[position];
      },
    );
  }

  @override
  void operator []=(final int index, final E value) {
    applyAction(
      ObservableListResultUpdateActionData<E, F>.update(
        <int, E>{index: value},
      ),
    );
  }

  @override
  void add(final E item) {
    applyAction(
      ObservableListResultUpdateActionData<E, F>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(null, <E>[item]),
        ],
      ),
    );
  }

  @override
  void addAll(final Iterable<E> items) {
    applyAction(
      ObservableListResultUpdateActionData<E, F>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(null, items),
        ],
      ),
    );
  }

  @override
  void clear() {
    value.when(
      onUndefined: () {},
      onFailure: (final _) {},
      onSuccess: (final UnmodifiableListView<E> data, final _) {
        applyAction(
          ObservableListResultUpdateActionData<E, F>.remove(
            <int>{for (int i = 0; i < data.length; i++) i},
          ),
        );
      },
    );
  }

  @override
  void applyAction(final ObservableListResultUpdateAction<E, F> action) {
    switch (action) {
      case final ObservableListResultUpdateActionFailure<E, F> actionFailure:
        final F failure = actionFailure.failure;
        value.when(
          onUndefined: () {
            super.value = _MutableStateFailure<E, F>(failure, <E>[]);
          },
          onFailure: (final F currentFailure) {
            super.value = _MutableStateFailure<E, F>(failure, <E>[]);
          },
          onSuccess: (final UnmodifiableListView<E> data, final _) {
            super.value = _MutableStateFailure<E, F>(
              failure,
              data.toList(),
            );
          },
        );
        break;
      case final ObservableListResultUpdateActionUndefined<E, F> _:
        value.when(
          onFailure: (final F failure) {
            super.value = _MutableStateUndefined<E, F>(<E>[]);
          },
          onSuccess: (final UnmodifiableListView<E> data, final _) {
            super.value = _MutableStateUndefined<E, F>(data.toList());
          },
        );
        break;
      case final ObservableListResultUpdateActionData<E, F> actionData:
        switch (value) {
          case final ObservableListResultStateData<E, F> stateData:
            final _MutableStateData<E, F> state = stateData as _MutableStateData<E, F>;
            final List<E> currentData = state._data;
            final ObservableListChange<E> change = actionData.apply(currentData);

            if (change.isEmpty) {
              return;
            }

            final _MutableStateData<E, F> newState = _MutableStateData<E, F>(
              currentData,
              change,
            );
            super.value = newState;
            break;
          case final ObservableListResultStateFailure<E, F> _:
            final List<E> data = <E>[];
            final ObservableListChange<E> change = actionData.apply(data);
            final _MutableStateData<E, F> newState = _MutableStateData<E, F>(
              _factory(data),
              change,
            );
            super.value = newState;
            break;
          case final ObservableListResultStateUndefined<E, F> _:
            final List<E> data = <E>[];
            final ObservableListChange<E> change = actionData.apply(data);
            final _MutableStateData<E, F> newState = _MutableStateData<E, F>(
              _factory(data),
              change,
            );
            super.value = newState;
            break;
        }
        break;
    }
  }

  @override
  set failure(final F failure) {
    applyAction(
      ObservableListResultUpdateActionFailure<E, F>(failure: failure),
    );
  }

  @override
  void insert(final int index, final E item) {
    applyAction(
      ObservableListResultUpdateActionData<E, F>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(index, <E>[item]),
        ],
      ),
    );
  }

  @override
  void insertAll(final int index, final Iterable<E> items) {
    applyAction(
      ObservableListResultUpdateActionData<E, F>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(index, items),
        ],
      ),
    );
  }

  @override
  void remove(final E item) {
    final int indexOf = value.fold(
      onUndefined: () => -1,
      onFailure: (final _) => -1,
      onSuccess: (final UnmodifiableListView<E> data, final _) => data.indexOf(item),
    );

    if (indexOf == -1) {
      return;
    }

    applyAction(
      ObservableListResultUpdateActionData<E, F>.remove(
        <int>{indexOf},
      ),
    );
  }

  @override
  void removeAt(final int index) {
    value.when(
      onSuccess: (final _, final __) {
        applyAction(
          ObservableListResultUpdateActionData<E, F>.remove(
            <int>{index},
          ),
        );
      },
    );
  }

  @override
  void removeWhere(final bool Function(E item) predicate) {
    final List<int> indexes = value.fold(
      onUndefined: () => <int>[],
      onFailure: (final _) => <int>[],
      onSuccess: (final UnmodifiableListView<E> data, final _) {
        final List<int> indexes = <int>[];

        for (int i = 0; i < data.length; i++) {
          if (predicate(data[i])) {
            indexes.add(i);
          }
        }

        return indexes;
      },
    );

    if (indexes.isEmpty) {
      return;
    }

    applyAction(
      ObservableListResultUpdateActionData<E, F>.remove(indexes),
    );
  }

  @override
  Observable<E?> rxItem(final int position) {
    return OperatorObservableListResultRxItem<E, F>(
      source: this,
      position: position,
    );
  }

  @override
  void setUndefined() {
    applyAction(
      ObservableListResultUpdateActionUndefined<E, F>(),
    );
  }
}
