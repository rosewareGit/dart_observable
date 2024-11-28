import 'dart:async';

import '../_impl.dart';

class StreamObservable<T> extends RxImpl<T> {
  final Stream<T> stream;
  StreamSubscription<T>? _subscription;

  StreamObservable({
    required this.stream,
    required final T initial,
    final bool distinct = true,
  }) : super(
          initial,
          distinct: distinct,
        );

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    _subscription?.cancel();
    _subscription = null;
  }

  void _startCollect() {
    if (_subscription != null) {
      return;
    }

    _subscription = stream.listen(
      (final T value) {
        this.value = value;
      },
      onError: (final Object error, final StackTrace stack) {
        dispatchError(error: error, stack: stack);
      },
      onDone: () {
        dispose();
      },
      cancelOnError: false,
    );

    addDisposeWorker(() {
      _subscription?.cancel();
      _subscription = null;
    });
  }
}
