import '../../../../dart_observable.dart';
import '../set/result.dart';

class OperatorCollectionsTransformAsSetResult<E, E2, F, C, T extends CollectionState<E, C>>
    extends RxSetResultImpl<E2, F> {
  final ObservableCollection<E, C, T> source;
  final void Function(
    ObservableSetResult<E2, F> state,
    C change,
    Emitter<ObservableSetResultUpdateAction<E2, F>> updater,
  ) transformFn;

  Disposable? _listener;

  OperatorCollectionsTransformAsSetResult({
    required this.source,
    required this.transformFn,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

  @override
  void onInit() {
    source.addDisposeWorker(() async {
      await _cancelListener();
      return dispose();
    });
    super.onInit();
  }

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  Future<void> _cancelListener() async {
    await _listener?.dispose();
    _listener = null;
  }

  late final List<C> _bufferedChanges = <C>[];

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final C change in _bufferedChanges) {
        transformFn(
          this,
          change,
          (final ObservableSetResultUpdateAction<E2, F> action) {
            applyAction(action);
          },
        );
      }
      _bufferedChanges.clear();
      return;
    }

    transformFn(
      this,
      source.value.asChange(),
      (final ObservableSetResultUpdateAction<E2, F> action) {
        applyAction(action);
      },
    );

    _listener = source.listen(
      onChange: (final Observable<T> source) {
        final T value = source.value;
        final C change = value.lastChange;
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _bufferedChanges.add(change);
          return;
        }

        transformFn(
          this,
          value.lastChange,
          (final ObservableSetResultUpdateAction<E2, F> action) {
            applyAction(action);
          },
        );
      },
    );
  }
}
