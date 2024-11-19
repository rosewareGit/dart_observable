import 'dart:async';

import '../../../../../dart_observable.dart';
import '../rx_impl.dart';

class ObservableListFromStream<E> extends RxListImpl<E> {
  final Stream<ObservableListUpdateAction<E>> stream;
  final List<E>? Function(dynamic error)? onError;

  StreamSubscription<ObservableListUpdateAction<E>>? _subscription;

  late final List<ObservableListUpdateAction<E>> _bufferedActions = <ObservableListUpdateAction<E>>[];

  ObservableListFromStream({
    required this.stream,
    required this.onError,
    final List<E>? initial,
  }) : super(
          initial: initial,
        );

  @override
  void onActive() {
    _startCollect();
    super.onActive();
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
      for (final ObservableListUpdateAction<E> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final ObservableListUpdateAction<E> action) {
        if (state == ObservableState.inactive) {
          _bufferedActions.add(action);
          return;
        }

        applyAction(action);
      },
      onError: (final Object error, final StackTrace stack) {
        final List<E>? Function(dynamic)? onError = this.onError;
        if (onError != null) {
          final List<E>? data = onError(error);
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
