import '../../../../dart_observable.dart';

class BaseTransformOperatorProxy<
    T, // Collection state for this
    T2 // Collection state for the transformed
    > {
  Disposable? _listener;
  final Observable<T> source;
  final Observable<T2> _current;
  final Function(T value) transform;

  late final List<T> _buffer = <T>[];

  BaseTransformOperatorProxy({
    required final Observable<T2> current,
    required this.source,
    required this.transform,
  }) : _current = current;

  void init() {
    final Disposable activeListener = _current.onActivityChanged(
      onActive: (final _) {
        _initListener();
      },
    );

    source.addDisposeWorker(() async {
      await activeListener.dispose();
      final Disposable? changeListener = _listener;
      if (changeListener != null) {
        await changeListener.dispose();
        _listener = null;
      }
      return _current.dispose();
    });
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final T change in _buffer) {
        transform(change);
      }
      _buffer.clear();
      return;
    }

    transform(source.value);

    _listener = source.listen(
      onChange: (final T value) {
        if (_current.state == ObservableState.inactive) {
          // store changes to apply when active
          _buffer.add(value);
          return;
        }

        transform(value);
      },
    );
  }
}
