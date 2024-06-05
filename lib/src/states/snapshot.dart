export 'extension/snapshot.dart';

sealed class Snapshot<T> {
  const Snapshot();

  factory Snapshot.data(final T data) = _SnapshotData<T>;

  factory Snapshot.undefined() = _SnapshotUndefined<T>;

  R fold<R>({
    required final R Function(T data) onData,
    required final R Function() onUndefined,
  }) {
    final Snapshot<T> $this = this;
    switch ($this) {
      case _SnapshotData<T>():
        return onData($this.data);
      case _SnapshotUndefined<T>():
        return onUndefined();
    }
  }

  void when({
    final void Function(T data)? onData,
    final void Function()? onUndefined,
  }) {
    final Snapshot<T> $this = this;
    switch ($this) {
      case _SnapshotData<T>():
        onData?.call($this.data);
        break;
      case _SnapshotUndefined<T>():
        onUndefined?.call();
        break;
    }
  }

  bool get isUndefined {
    return fold(
      onData: (final _) => false,
      onUndefined: () => true,
    );
  }

  T? get data {
    return fold(
      onData: (final T data) => data,
      onUndefined: () => null,
    );
  }
}

class _SnapshotData<T> extends Snapshot<T> {
  @override
  final T data;

  _SnapshotData(this.data);

  @override
  bool operator ==(final Object other) {
    return other is _SnapshotData<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

class _SnapshotUndefined<T> extends Snapshot<T> {
  @override
  bool operator ==(final Object other) {
    return other is _SnapshotUndefined<T>;
  }

  @override
  int get hashCode => 0;
}
