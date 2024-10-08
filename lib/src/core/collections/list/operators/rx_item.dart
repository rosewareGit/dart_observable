import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableListRxItem<E> extends RxnImpl<E> {
  final ObservableList<E> source;
  final int index;

  Disposable? _listener;

  OperatorObservableListRxItem({
    required this.source,
    required this.index,
  }) : super(
          value: source.value.listView.length > index ? source.value.listView[index] : null,
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

  void _handleInitialState() {
    final E? initial = source.value.listView.length > index ? source.value.listView[index] : null;
    if (initial != null) {
      value = initial;
    }
  }

  void _initListener() {
    if (_listener != null) {
      return;
    }

    _handleInitialState();

    _listener = source.listen(
      onChange: (final ObservableListState<E> value) {
        final ObservableListChange<E> change = value.lastChange;

        final E? added = change.added[index];
        if (added != null) {
          this.value = added;
          return;
        }

        final ObservableItemChange<E>? updated = change.updated[index];
        if (updated != null) {
          this.value = updated.newValue;
          return;
        }

        final E? removed = change.removed[index];
        if (removed != null) {
          this.value = value.listView.length > index ? value.listView[index] : null;
        }
      },
    );
  }
}
