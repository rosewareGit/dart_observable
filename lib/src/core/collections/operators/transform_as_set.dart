import '../../../../dart_observable.dart';
import '../set/set.dart';

// TODO generic approach, its the same as the map
class OperatorCollectionsTransformAsSet<E, E2, C, T extends CollectionState<E, C>> extends RxSetImpl<E2> {
  final ObservableCollection<E, C, T> source;
  final void Function(
    C change,
    Emitter<ObservableSetUpdateAction<E2>> updater,
  ) transformFn;

  Disposable? _listener;

  late final List<C> _bufferedChanges = <C>[];

  OperatorCollectionsTransformAsSet({
    required this.source,
    required this.transformFn,
    final Set<E2> Function(Iterable<E2>? items)? factory,
  }) : super(factory: factory);

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
          change,
          (final ObservableSetUpdateAction<E2> action) {
            applyAction(action);
          },
        );
      }
      _bufferedChanges.clear();
      return;
    }

    transformFn(
      source.value.asChange(),
      (final ObservableSetUpdateAction<E2> action) {
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
          value.lastChange,
          (final ObservableSetUpdateAction<E2> action) {
            applyAction(action);
          },
        );
      },
    );
  }
}
