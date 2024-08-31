import '../../../../../../dart_observable.dart';
import '../../../../rx/_impl.dart';

StateOf<V?, S> _getStateForKey<K, V, S>({
  required final ObservableMapStatefulState<K, V, S> state,
  required final K key,
  required final bool isInitial,
}) {
  return state.fold(
    onData: (final ObservableMapState<K, V> map) {
      return StateOf<V?, S>.data(map.mapView[key]);
    },
    onCustom: (final S state) {
      return StateOf<V?, S>.custom(state);
    },
  );
}

class OperatorObservableMapStatefulRxItem<Self extends ObservableMapStateful<Self, K, V, S>, K, V, S>
    extends RxImpl<StateOf<V?, S>> {
  final K key;
  final Self source;

  Disposable? _listener;

  OperatorObservableMapStatefulRxItem({
    required this.source,
    required this.key,
  }) : super(
          _getStateForKey(state: source.value, key: key, isInitial: true),
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

    final StateOf<V?, S> newState = _getStateForKey(state: source.value, key: key, isInitial: true);
    value = newState;

    _listener = source.listen(
      onChange: (final Self source) {
        final ObservableMapStatefulState<K, V, S> state = source.value;
        final StateOf<V?, S> newState = _getStateForKey(state: state, key: key, isInitial: false);
        value = newState;
      },
    );
  }
}
