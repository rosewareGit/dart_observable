import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';

mixin BaseCollectionTransformOperator<
    E, //
    E2,
    C,
    T extends CollectionState<E, C>,
    C2,
    T2 extends CollectionState<E2, C2>,
    S extends ObservableCollection<E2, C2, T2>,
    U extends ObservableCollectionUpdateAction> on RxImpl<T2> {
  ObservableCollection<E, C, T> get source;

  void applyAction(final U action);

  S get current;

  Disposable? _listener;
  late final List<C> _bufferedChanges = <C>[];

  void Function(
    S state,
    C change,
    Emitter<U> updater,
  ) get transformFn;

  @override
  void onActive() {
    super.onActive();
    _initListener();
  }

  @override
  void onInit() {
    source.addDisposeWorker(() async {
      await _cancelListener();
      return dispose();
    });
    super.onInit();
  }

  Future<void> _cancelListener() async {
    await _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final C change in _bufferedChanges) {
        transformFn(
          current,
          change,
          (final U action) {
            applyAction(action);
          },
        );
      }
      _bufferedChanges.clear();
      return;
    }

    transformFn(
      current,
      source.value.asChange(),
      (final U action) {
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
          current,
          value.lastChange,
          (final U action) {
            applyAction(action);
          },
        );
      },
    );
  }
}
