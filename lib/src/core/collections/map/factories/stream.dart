import 'dart:async';

import '../../../../../dart_observable.dart';
import '../map.dart';

class ObservableMapFromStream<K, V> extends RxMapImpl<K, V> {
  ObservableMapFromStream({
    required this.stream,
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(
          initial: initial,
          factory: factory,
        );

  final Stream<ObservableMapUpdateAction<K, V>> stream;
  StreamSubscription<ObservableMapUpdateAction<K, V>>? _subscription;

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
      (final ObservableMapUpdateAction<K, V> action) {
        applyAction(action);
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
      return _subscription?.cancel().then((_) {
        _subscription = null;
      });
    });
  }
}
