import '../snapshot_result.dart';

extension ExtensionSnapshotResult<T, F> on SnapshotResult<T, F> {
  R combineWith<R, T2>({
    required final SnapshotResult<T2, dynamic> other,
    required final R Function(T data1, T2 data2) onData,
    required final R Function() onFailure,
    required final R Function() onUndefined,
  }) {
    if (isUndefined || other.isUndefined) {
      return onUndefined();
    }

    if (failure != null || other.failure != null) {
      return onFailure();
    }

    final T? value1 = success;
    final T2? value2 = other.success;

    if (value1 is T && value2 is T2) {
      return onData(value1, value2);
    }

    throw StateError('Unexpected state');
  }
}
