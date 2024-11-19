import 'dart:async';

import '../../../../../../dart_observable.dart';
import '../rx_stateful.dart';
import '../state.dart';

class ObservableStatefulListFromStream<E, S> extends RxStatefulListImpl<E, S> {
  final Stream<Either<ObservableListUpdateAction<E>, S>> stream;
  final Either<List<E>, S>? Function(dynamic error)? onError;
  StreamSubscription<Either<ObservableListUpdateAction<E>, S>>? _subscription;

  late final List<Either<ObservableListUpdateAction<E>, S>> _bufferedActions =
      <Either<ObservableListUpdateAction<E>, S>>[];

  ObservableStatefulListFromStream({
    required this.stream,
    required this.onError,
    final ObservableStatefulListState<E, S>? initial,
  }) : super.state(initial ?? RxStatefulListState<E, S>.fromList(<E>[]));

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
      for (final Either<ObservableListUpdateAction<E>, S> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final Either<ObservableListUpdateAction<E>, S> action) {
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
