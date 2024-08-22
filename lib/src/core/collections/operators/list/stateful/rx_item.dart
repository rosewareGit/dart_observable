import '../../../../../../dart_observable.dart';
import '../../../../rx/_impl.dart';

class OperatorObservableListStatefulRxItem<Self extends ObservableListStateful<Self, E, S>, E, S>
    extends RxImpl<StateOf<E?, S>> {
  final int position;
  final Self source;

  Disposable? _listener;

  OperatorObservableListStatefulRxItem({
    required this.source,
    required this.position,
  }) : super(
          _getStateForIndex(state: source.value, position: position, isInitial: true) ?? StateOf<E?, S>.data(null),
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

    final StateOf<E?, S>? newState = _getStateForIndex(state: source.value, position: position, isInitial: true);
    if (newState != null) {
      value = newState;
    }

    _listener = source.listen(
      onChange: (final Self source) {
        final ObservableListStatefulState<E, S> state = source.value;
        final StateOf<E?, S>? newState = _getStateForIndex(state: state, position: position, isInitial: false);
        if (newState != null) {
          value = newState;
        }
      },
    );
  }
}

StateOf<E?, S>? _getStateForIndex<E, S>({
  required final ObservableListStatefulState<E, S> state,
  required final int position,
  required final bool isInitial,
}) {
  return state.fold(
    onData: (final ObservableListState<E> list) {
      final ObservableListChange<E> change = isInitial ? list.asChange() : list.lastChange;
      if (change.removed.containsKey(position)) {
        return StateOf<E?, S>.data(null);
      } else if (change.added.containsKey(position)) {
        return StateOf<E?, S>.data(change.added[position]);
      } else if (change.updated.containsKey(position)) {
        return StateOf<E?, S>.data(change.updated[position]?.newValue);
      }
      return null;
    },
    onCustom: (final S state) {
      return StateOf<E?, S>.custom(state);
    },
  );
}
