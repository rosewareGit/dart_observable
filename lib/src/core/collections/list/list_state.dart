import 'dart:collection';

import '../../../../dart_observable.dart';

class RxListState<E> extends ObservableListState<E> {
  final List<E> _data;

  List<E> get data => _data;

  final ObservableListChange<E> change;

  RxListState.initial(final Iterable<E> initial)
      : _data = initial.toList(),
        change = ObservableListChange<E>(
          added: () {
            final List<E> list = initial.toList();
            return <int, E>{
              for (int i = 0; i < initial.length; i++) i: list[i],
            };
          }(),
        );

  RxListState(final List<E> list, this.change) : _data = list;

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
