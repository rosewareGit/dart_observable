import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableMapRxItem<K, V> extends RxnImpl<V?> {
  final K key;
  final ObservableMap<K, V> source;

  Disposable? _listener;

  OperatorObservableMapRxItem({
    required this.source,
    required this.key,
  }) : super(
          value: source[key],
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

    // Update initial value
    value = source[key];

    _listener = source.onChange(
      onChange: (final  ObservableMapChange<K, V> change) {
        if (state == ObservableState.inactive) {
          return;
        }

        if (change.removed.containsKey(key)) {
          value = null;
        } else if (change.added.containsKey(key)) {
          value = change.added[key];
        } else if (change.updated.containsKey(key)) {
          value = change.updated[key]?.newValue;
        }
      },
    );
  }
}
