import '../../../../../../dart_observable.dart';
import '../../../../rx/_impl.dart';

Either<E?, S>? _getStateForIndex<E, S>({
  required final ObservableStatefulListState<E, S> state,
  required final int position,
  required final bool isInitial,
}) {
  return state.fold(
    onData: (final ObservableListState<E> list) {
      final ObservableListChange<E> change = isInitial ? list.asChange() : list.lastChange;
      if (change.removed.containsKey(position)) {
        return Either<E?, S>.left(state.leftOrNull?.listView.elementAtOrNull(position));
      } else if (change.added.containsKey(position)) {
        return Either<E?, S>.left(change.added[position]);
      } else if (change.updated.containsKey(position)) {
        return Either<E?, S>.left(change.updated[position]?.newValue);
      }
      return null;
    },
    onCustom: (final S state) {
      return Either<E?, S>.right(state);
    },
  );
}

class OperatorObservableListStatefulRxItem<E, S> extends RxImpl<Either<E?, S>> {
  final int position;
  final ObservableStatefulList<E, S> source;

  Disposable? _listener;

  OperatorObservableListStatefulRxItem({
    required this.source,
    required this.position,
  }) : super(
          _getStateForIndex(state: source.value, position: position, isInitial: true) ?? Either<E?, S>.left(null),
        );

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  Future<void> onInactive() async {
    await super.onInactive();
    _cancelListener();
  }

  @override
  void onInit() {
    source.addDisposeWorker(() {
      return dispose();
    });
    super.onInit();
  }

  void _cancelListener() {
    _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    final Either<E?, S>? newState = _getStateForIndex(state: source.value, position: position, isInitial: true);
    if (newState != null) {
      value = newState;
    }

    _listener = source.listen(
      onChange: (final ObservableStatefulListState<E, S> value) {
        final Either<E?, S>? newState = _getStateForIndex(state: value, position: position, isInitial: false);
        if (newState != null) {
          this.value = newState;
        }
      },
    );
  }
}
