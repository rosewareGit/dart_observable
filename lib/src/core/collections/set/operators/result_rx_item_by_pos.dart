import 'package:collection/collection.dart';

import '../../../../../dart_observable.dart';
import '../../../rx/_impl.dart';

class OperatorObservableSetResultRxItemByPos<E, F> extends RxImpl<SnapshotResult<E?, F>> {
  final int index;
  final ObservableSetResult<E, F> source;

  Disposable? _listener;

  OperatorObservableSetResultRxItemByPos({
    required this.source,
    required this.index,
  }) : super(
          source.value.fold(
            onUndefined: () => SnapshotResult<E, F>.undefined(),
            onFailure: (final F failure) => SnapshotResult<E, F>.failure(failure),
            onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
              final E? item = data.elementAtOrNull(index);
              return SnapshotResult<E?, F>.success(item);
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

    source.value.fold(
      onUndefined: () => SnapshotResult<E, F>.undefined(),
      onFailure: (final F failure) => SnapshotResult<E, F>.failure(failure),
      onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
        final E? item = data.elementAtOrNull(index);
        return SnapshotResult<E?, F>.success(item);
      },
    );

    _listener = source.listen(
      onChange: (final Observable<ObservableSetResultState<E, F>> source) {
        final ObservableSetResultState<E, F> state = source.value;

        state.when(
          onUndefined: () {
            value = SnapshotResult<E?, F>.undefined();
          },
          onFailure: (final F failure) {
            value = SnapshotResult<E?, F>.failure(failure);
          },
          onSuccess: (final UnmodifiableSetView<E> data, final ObservableSetChange<E> change) {
            if (change.isEmpty) {
              value.when(
                onUndefined: () {
                  value = SnapshotResult<E?, F>.success(null);
                },
                onFailure: (_) {
                  value = SnapshotResult<E?, F>.success(null);
                },
              );
              return;
            }

            final E? item = data.elementAtOrNull(index);
            value = SnapshotResult<E?, F>.success(item);
          },
        );
      },
    );
  }
}
