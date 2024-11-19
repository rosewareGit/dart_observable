import '../../../../../../dart_observable.dart';
import '../../../../rx/_impl.dart';

Either<E?, S>? _getStateForIndex<E, S>({
  required final ObservableStatefulList<E, S> source,
  required final int position,
  required final bool isInitial,
}) {
  final ObservableStatefulListState<E, S> value = source.value;
  return value.fold(
    onData: (final ObservableListState<E> list) {
      return Either<E?, S>.left(source[position]);
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
          _getStateForIndex(source: source, position: position, isInitial: true) ?? Either<E?, S>.left(null),
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

    final Either<E?, S>? newState = _getStateForIndex(source: source, position: position, isInitial: true);
    if (newState != null) {
      value = newState;
    }

    _listener = source.listen(
      onChange: (final ObservableStatefulListState<E, S> value) {
        final Either<E?, S>? newState = _getStateForIndex(source: source, position: position, isInitial: false);
        if (newState != null) {
          this.value = newState;
        }
      },
    );
  }
}
