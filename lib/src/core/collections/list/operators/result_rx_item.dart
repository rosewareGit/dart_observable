import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableListResultRxItem<E, F> extends RxnImpl<E> {
  final int position;
  final ObservableListResult<E, F> source;

  Disposable? _listener;

  OperatorObservableListResultRxItem({
    required this.source,
    required this.position,
  }) : super(
          value: source[position],
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

    _listener = source.listen(
      onChange: (final Observable<ObservableListResultState<E, F>> source) {
        final ObservableListResultState<E, F> state = source.value;

        state.when(
          onUndefined: () {
            value = null;
          },
          onFailure: (final F failure) {
            value = null;
          },
          onSuccess: (final _, final ObservableListChange<E> change) {
            if (change.removed.containsKey(position)) {
              value = null;
            } else if (change.added.containsKey(position)) {
              value = change.added[position];
            } else if (change.updated.containsKey(position)) {
              value = change.updated[position]?.newValue;
            }
          },
        );
      },
    );
  }
}
