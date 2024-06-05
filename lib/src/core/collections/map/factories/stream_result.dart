import 'dart:async';

import '../../../../../dart_observable.dart';
import '../result.dart';

class ObservableMapResultFromStream<K, V, F> extends RxMapResultImpl<K, V, F> {
  final Stream<ObservableMapResultUpdateAction<K, V, F>> stream;
  final F Function(Object error)? onError;

  StreamSubscription<ObservableMapResultUpdateAction<K, V, F>>? _subscription;

  ObservableMapResultFromStream({
    required this.stream,
    this.onError,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(factory: factory);

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
      (final ObservableMapResultUpdateAction<K, V, F> action) {
        applyAction(action);
      },
      onError: (final Object error, final StackTrace stack) {
        final F? failure = onError?.call(error);
        if (failure != null) {
          applyAction(ObservableMapResultUpdateActionFailure<K, V, F>(failure: failure));
        } else {
          dispatchError(error: error, stack: stack);
        }
      },
      onDone: () {
        dispose();
      },
      cancelOnError: false,
    );

    addDisposeWorker(() {
      return _subscription?.cancel().then((final _) {
        _subscription = null;
      });
    });
  }
}
