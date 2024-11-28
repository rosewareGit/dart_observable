import 'dart:async';

import '../../../../../../dart_observable.dart';
import '../rx_stateful.dart';

class ObservableStatefulListFromStream<E, S> extends RxStatefulListImpl<E, S> {
  final Stream<StatefulListAction<E,S>> stream;
  final Either<List<E>, S>? Function(dynamic error)? onError;
  StreamSubscription<StatefulListAction<E,S>>? _subscription;

  late final List<StatefulListAction<E,S>> _bufferedActions =
      <StatefulListAction<E,S>>[];

  ObservableStatefulListFromStream({
    required this.stream,
    required this.onError,
    final Either<List<E>, S>? initial,
  }) : super.state(initial ?? Either<List<E>, S>.left(<E>[]));

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
      for (final StatefulListAction<E,S> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final StatefulListAction<E,S> action) {
        if (state == ObservableState.inactive) {
          _bufferedActions.add(action);
          return;
        }

        applyAction(action);
      },
      onError: (final Object error, final StackTrace stack) {
        final Either<List<E>, S>? Function(dynamic)? onError = this.onError;
        if (onError != null) {
          final Either<List<E>, S>? newState = onError(error);
          if (newState != null) {
            newState.fold(
              onLeft: (final List<E> list) => setData(list),
              onRight: (final S custom) => setState(custom),
            );
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
