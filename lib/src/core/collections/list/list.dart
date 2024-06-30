import 'dart:collection';

import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';
import '../_base.dart';
import 'operators/filter.dart';
import 'operators/rx_item.dart';

List<E> Function(Iterable<E>? items) _defaultListFactory<E>() {
  return (final Iterable<E>? items) {
    return List<E>.of(items ?? <E>{});
  };
}

class RxListImpl<E> extends RxImpl<ObservableListState<E>>
    with ObservableCollectionBase<E, ObservableListChange<E>, ObservableListState<E>>
    implements RxList<E> {
  RxListImpl({
    final Iterable<E>? initial,
    final List<E> Function(Iterable<E>? items)? factory,
  }) : super(_MutableState<E>.initial((factory ?? _defaultListFactory<E>()).call(initial)));

  @override
  int get length => _value._data.length;

  _MutableState<E> get _value => value as _MutableState<E>;

  @override
  E? operator [](final int position) {
    return _value._data[position];
  }

  @override
  void operator []=(final int index, final E value) {
    applyAction(
      ObservableListUpdateAction<E>.update(
        <int, E>{index: value},
      ),
    );
  }

  @override
  ObservableListChange<E>? add(final E item) {
    return applyAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(null, <E>[item]),
        ],
      ),
    );
  }

  @override
  ObservableListChange<E>? addAll(final Iterable<E> items) {
    return applyAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(null, items),
        ],
      ),
    );
  }

  @override
  ObservableListChange<E>? applyAction(final ObservableListUpdateAction<E> action) {
    if (action.isEmpty) {
      return null;
    }

    final List<E> updated = _value._data;
    final ObservableListChange<E> change = action.apply(updated);
    if (change.isEmpty) {
      return null;
    }
    value = _MutableState<E>._(
      updated,
      change,
    );
    return change;
  }

  @override
  ObservableList<E> filterList({
    required final bool Function(E item) predicate,
    final FactoryList<E>? factory,
  }) {
    return ObservableListFilterOperator<E>(
      source: this,
      predicate: predicate,
      factory: factory,
    );
  }

  @override
  ObservableList<E2> flatMapList<E2>({
    required final ObservableList<E2>? Function(
      ObservableListChange<E> change,
      ObservableList<E> source,
    ) sourceProvider,
    final FactoryList<E2>? factory,
  }) {}

  @override
  ObservableListChange<E>? insert(final int index, final E item) {
    return applyAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(index, <E>[item]),
        ],
      ),
    );
  }

  @override
  ObservableListChange<E>? insertAll(final int index, final Iterable<E> items) {
    return applyAction(
      ObservableListUpdateAction<E>.add(
        <MapEntry<int?, Iterable<E>>>[
          MapEntry<int?, Iterable<E>>(index, items),
        ],
      ),
    );
  }

  @override
  ObservableListResult<E, F> mapAsListResult<F>({
    final ObservableListResultUpdateAction<E, F> Function(
      ObservableListChange<E> change,
      ObservableList<E> source,
    )? changeHandler,
    final FactoryList<E>? factory,
  }) {}

  @override
  ObservableMap<K, E> mapAsMap<K>({
    required final K Function(E item) keyProvider,
    final FactoryMap<K, E>? factory,
  }) {}

  @override
  ObservableMapResult<K, E, F> mapAsMapResult<K, F>({
    required final K Function(E item) keyProvider,
    final FactoryMap<K, E>? factory,
    final ObservableMapResultUpdateAction<K, E, F> Function(
      ObservableMapChange<K, E> change,
      ObservableList<E> source,
    )? changeHandler,
  }) {}

  @override
  ObservableSet<E> mapAsSet({final FactorySet<E>? factory}) {}

  @override
  ObservableSetResult<E, F> mapAsSetResult<F>({
    final ObservableSetResultUpdateAction<E, F> Function(
      ObservableSetChange<E> change,
      ObservableList<E> source,
    )? changeHandler,
    final FactorySet<E>? factory,
  }) {}

  @override
  ObservableListChange<E>? remove(final E item) {
    final int index = _value._data.indexOf(item);
    if (index == -1) {
      return null;
    }
    return applyAction(
      ObservableListUpdateAction<E>.remove(<int>{index}),
    );
  }

  @override
  ObservableListChange<E>? removeAt(final int index) {
    return applyAction(
      ObservableListUpdateAction<E>.remove(<int>{index}),
    );
  }

  @override
  ObservableListChange<E>? removeWhere(final bool Function(E item) predicate) {
    final Set<int> removed = <int>{};
    for (int i = 0; i < _value._data.length; i++) {
      if (predicate(_value._data[i])) {
        removed.add(i);
      }
    }
    if (removed.isEmpty) {
      return null;
    }
    return applyAction(
      ObservableListUpdateAction<E>.remove(removed),
    );
  }

  @override
  Observable<E?> rxItem(final int position) {
    return OperatorObservableListRxItem<E>(
      source: this,
      index: position,
    );
  }
}

class _MutableState<E> extends ObservableListState<E> {
  final List<E> _data;

  final ObservableListChange<E> change;

  _MutableState.initial(final Iterable<E> initial)
      : _data = initial.toList(),
        change = ObservableListChange<E>(
          added: () {
            final List<E> list = initial.toList();
            return <int, E>{
              for (int i = 0; i < initial.length; i++) i: list[i],
            };
          }(),
        );

  _MutableState._(final List<E> list, this.change) : _data = list;

  @override
  ObservableListChange<E> get lastChange => change;

  @override
  UnmodifiableListView<E> get listView => UnmodifiableListView<E>(_data);

  @override
  ObservableListChange<E> asChange() {
    return ObservableListChange<E>(
      added: () {
        final Map<int, E> initial = <int, E>{};

        for (int i = 0; i < _data.length; i++) {
          initial[i] = _data[i];
        }

        return initial;
      }(),
    );
  }
}
