import 'dart:async';

import '../../../../../../dart_observable.dart';
import '../rx_stateful.dart';

class ObservableStatefulMapFromStream<K, V, S> extends RxStatefulMapImpl<K, V, S> {
  final Stream<Either<ObservableMapUpdateAction<K, V>, S>> stream;
  StreamSubscription<Either<ObservableMapUpdateAction<K, V>, S>>? _subscription;

  late final List<Either<ObservableMapUpdateAction<K, V>, S>> _bufferedActions =
      <Either<ObservableMapUpdateAction<K, V>, S>>[];

  ObservableStatefulMapFromStream({
    required this.stream,
    final Map<K, V>? initial,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(
          initial ?? <K, V>{},
          factory: factory,
        );

  @override
  void onActive() {
    super.onActive();
    _startCollect();
  }

  @override
  void onInit() {
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
      for (final Either<ObservableMapUpdateAction<K, V>, S> action in _bufferedActions) {
        applyAction(action);
      }
      _bufferedActions.clear();
      return;
    }

    _subscription = stream.listen(
      (final Either<ObservableMapUpdateAction<K, V>, S> action) {
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
