import 'package:collection/collection.dart';

import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableSetRxItem<E> extends RxnImpl<E> {
  final bool Function(E item) predicate;
  final ObservableSet<E> source;

  Disposable? _listener;

  OperatorObservableSetRxItem({
    required this.source,
    required this.predicate,
  }) : super(
          value: source.value.firstWhereOrNull(predicate),
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
    final E? initial = source.value.firstWhereOrNull(predicate);
    value = initial;

    _listener = source.onChange(
      onChange: (final ObservableSetChange<E> change) {
        final E? added = change.added.firstWhereOrNull(predicate);
        if (added != null) {
          value = added;
          return;
        }
        final E? removed = change.removed.firstWhereOrNull(predicate);
        if (removed != null) {
          value = null;
        }
      },
    );
  }
}
