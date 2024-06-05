import '../snapshot.dart';

extension ExtensionSnapshot<T> on Snapshot<T> {
  R combineWith<R, T2>({
    required final Snapshot<T2> other,
    required final R Function(T data1, T2 data2) onData,
    required final R Function() onUndefined,
  }) {
    if (isUndefined || other.isUndefined) {
      return onUndefined();
    }

    final T? value1 = data;
    final T2? value2 = other.data;

    if (value1 is T && value2 is T2) {
      return onData(value1, value2);
    }

    throw StateError('Unexpected state');
  }
}
