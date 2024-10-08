import '../../../../../dart_observable.dart';
import '../../../../utils/extensions/iterable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableSetRxItem<E> extends RxnImpl<E> {
  final bool Function(E item) predicate;
  final ObservableSet<E> source;

  Disposable? _listener;

  OperatorObservableSetRxItem({
    required this.source,
    required this.predicate,
  }) : super(
          value: source.value.setView.firstWhereOrNull(predicate),
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

    // initial value
    final E? initial = source.value.setView.firstWhereOrNull(predicate);
    value = initial;

    _listener = source.listen(
      onChange: (final ObservableSetState<E> value) {
        final ObservableSetChange<E> change = value.lastChange;

        final E? added = change.added.firstWhereOrNull(predicate);
        if (added != null) {
          this.value = added;
          return;
        }
        final E? removed = change.removed.firstWhereOrNull(predicate);
        if (removed != null) {
          this.value = null;
        }
      },
    );
  }
}
