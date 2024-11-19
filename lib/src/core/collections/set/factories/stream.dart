import 'dart:async';

import '../../../../../dart_observable.dart';
import '../rx_impl.dart';

class ObservableSetFromStream<E> extends RxSetImpl<E> {
  final Stream<ObservableSetUpdateAction<E>> stream;
  final Set<E>? Function(dynamic error)? onError;

  StreamSubscription<ObservableSetUpdateAction<E>>? _subscription;

  late final List<ObservableSetUpdateAction<E>> _bufferedActions = <ObservableSetUpdateAction<E>>[];

  ObservableSetFromStream({
    required this.stream,
    required this.onError,
    required super.factory,
    final Set<E>? initial,
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
      for (final ObservableSetUpdateAction<E> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final ObservableSetUpdateAction<E> action) {
        if (state == ObservableState.inactive) {
          _bufferedActions.add(action);
          return;
        }

        applyAction(action);
      },
      onError: (final Object error, final StackTrace stack) {
        final Set<E>? Function(dynamic)? onError = this.onError;
        if (onError != null) {
          final Set<E>? data = onError(error);
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
