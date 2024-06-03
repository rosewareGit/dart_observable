import 'package:collection/collection.dart';

import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableSetResultRxItem<E, F> extends RxnImpl<E> {
  final bool Function(E item) predicate;
  final ObservableSetResult<E, F> source;

  Disposable? _listener;

  OperatorObservableSetResultRxItem({
    required this.source,
    required this.predicate,
  }) : super(
          value: source.value.fold(
            onUndefined: () => null,
            onFailure: (_) => null,
            onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
              final E? item = data.firstWhereOrNull(predicate);
              return item;
            },
          ),
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
      onChange: (final Observable<ObservableSetResultState<E, F>> source) {
        final ObservableSetResultState<E, F> state = source.value;

        state.when(
          onUndefined: () {
            value = null;
          },
          onFailure: (_) {
            value = null;
          },
          onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
            if (change.isEmpty) {
              return;
            }

            final E? added = change.added.firstWhereOrNull(predicate);
            if (added != null) {
              value = added;
              return;
            }

            final E? removed = change.removed.firstWhereOrNull(predicate);
            if (removed != null) {
              value = null;
              return;
            }
          },
        );
      },
    );
  }
}
