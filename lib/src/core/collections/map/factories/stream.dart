import 'dart:async';

import '../../../../../dart_observable.dart';
import '../rx_impl.dart';

class ObservableMapFromStream<K, V> extends RxMapImpl<K, V> {
  final Stream<ObservableMapUpdateAction<K, V>> stream;
  final Map<K, V>? Function(dynamic error)? onError;

  StreamSubscription<ObservableMapUpdateAction<K, V>>? _subscription;

  late final List<ObservableMapUpdateAction<K, V>> _bufferedActions = <ObservableMapUpdateAction<K, V>>[];

  ObservableMapFromStream({
    required this.stream,
    required this.onError,
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(
          initial: initial,
          factory: factory,
        );

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  void onInit() {
    _startCollect();
    addDisposeWorker(() {
      return _subscription?.cancel().then((final _) {
        _subscription = null;
      });
    });
    super.onInit();
  }

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
        final Map<K, V>? Function(dynamic)? onError = this.onError;
        if (onError != null) {
          final Map<K, V>? data = onError(error);
          if (data != null) {
            setData(data);
          }
        } else {
          dispatchError(error: error, stack: stack);
        }
      },
      onDone: () {
        dispose();
      },
      cancelOnError: false,
    );
  }
}
