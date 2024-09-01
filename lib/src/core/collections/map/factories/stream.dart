import 'dart:async';

import '../../../../../dart_observable.dart';
import '../rx_impl.dart';

class ObservableMapFromStream<K, V> extends RxMapImpl<K, V> {
  final Stream<ObservableMapUpdateAction<K, V>> stream;
  StreamSubscription<ObservableMapUpdateAction<K, V>>? _subscription;

  ObservableMapFromStream({
    required this.stream,
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(
          initial: initial,
          factory: factory,
        );

  @override
  void onInit() {
    addDisposeWorker(() {
      return _subscription?.cancel().then((final _) {
        _subscription = null;
      });
    });
    super.onInit();
  }

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  late final List<ObservableMapUpdateAction<K, V>> _bufferedActions = <ObservableMapUpdateAction<K, V>>[];

  void _startCollect() {
    if (_subscription != null) {
      // apply buffered actions
      for (final ObservableMapUpdateAction<K, V> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final ObservableMapUpdateAction<K, V> action) {
        if (state == ObservableState.inactive) {
          _bufferedActions.add(action);
          return;
        }

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
  }
}
