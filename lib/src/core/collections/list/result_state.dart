part of 'result.dart';

class _MutableStateData<E, F> extends ObservableListResultStateData<E, F> {
  final List<E> _data;

  @override
  final ObservableListChange<E> change;

  _MutableStateData(this._data, this.change);

  @override
  UnmodifiableListView<E> get data => UnmodifiableListView<E>(_data);

  @override
  int get hashCode {
    return _data.hashCode ^ change.hashCode;
  }

  @override
  ObservableListResultChange<E, F> get lastChange => ObservableListResultChangeData<E, F>(
        change: change,
        data: data,
      );

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is _MutableStateData<E, F> && other._data == _data && other.change == change;
  }

  @override
  ObservableListResultChange<E, F> asChange() {
    return ObservableListResultChangeData<E, F>(
      change: ObservableListChange<E>(
        added: <int, E>{
          for (int i = 0; i < _data.length; i++) i: _data[i],
        },
      ),
      data: data,
    );
  }
}

class _MutableStateFailure<E, F> extends ObservableListResultStateFailure<E, F> {
  @override
  final F failure;

  @override
  final List<E> removedItems;

  _MutableStateFailure(this.failure, this.removedItems);

  @override
  int get hashCode {
    return failure.hashCode ^ removedItems.hashCode;
  }

  @override
  ObservableListResultChange<E, F> get lastChange => ObservableListResultChangeFailure<E, F>(
        failure: failure,
        removedItems: removedItems,
      );

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is _MutableStateFailure<E, F> && other.failure == failure && other.removedItems == removedItems;
  }

  @override
  ObservableListResultChange<E, F> asChange() {
    return ObservableListResultChangeFailure<E, F>(
      failure: failure,
      removedItems: removedItems,
    );
  }
}

class _MutableStateUndefined<E, F> extends ObservableListResultStateUndefined<E, F> {
  @override
  final List<E> removedItems;

  _MutableStateUndefined(this.removedItems);

  @override
  int get hashCode {
    return removedItems.hashCode;
  }

  @override
  ObservableListResultChange<E, F> get lastChange => ObservableListResultChangeUndefined<E, F>(
        removedItems: removedItems,
      );

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) return true;

    return other is _MutableStateUndefined<E, F> && other.removedItems == removedItems;
  }

  @override
  ObservableListResultChange<E, F> asChange() {
    return ObservableListResultChangeUndefined<E, F>(removedItems: removedItems);
  }
}
