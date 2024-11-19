import 'dart:async';

import '../../../../../../dart_observable.dart';
import '../rx_stateful.dart';

class ObservableStatefulSetFromStream<E, S> extends RxStatefulSetImpl<E, S> {
  final Stream<Either<ObservableSetUpdateAction<E>, S>> stream;
  final Either<Set<E>, S>? Function(dynamic error)? onError;

  StreamSubscription<Either<ObservableSetUpdateAction<E>, S>>? _subscription;

  late final List<Either<ObservableSetUpdateAction<E>, S>> _bufferedActions =
      <Either<ObservableSetUpdateAction<E>, S>>[];

  ObservableStatefulSetFromStream({
    required this.stream,
    required this.onError,
    required super.factory,
    final Set<E>? initial,
  }) : super(
          initial ?? <E>{},
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
      for (final Either<ObservableSetUpdateAction<E>, S> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final Either<ObservableSetUpdateAction<E>, S> action) {
        if (state == ObservableState.inactive) {
          _bufferedActions.add(action);
          return;
        }

        applyAction(action);
      },
      onError: (final Object error, final StackTrace stack) {
        final Either<Set<E>, S>? Function(dynamic)? onError = this.onError;
        if (onError != null) {
          final Either<Set<E>, S>? data = onError(error);
          if (data != null) {
            data.fold(
              onLeft: (final Set<E> data) {
                setData(data);
              },
              onRight: (final S state) {
                setState(state);
              },
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
