import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';
import '../../rx/base_tracking.dart';

mixin BaseCollectionTransformOperator<
    Self extends ChangeTrackingObservable<Self, CS, C>,
    Current extends ChangeTrackingObservable<Current, CS2, C2>,
    CS, // Collection state for this
    CS2, // Collection state for the transformed
    C,
    C2,
    U> on RxBaseTracking<Current, CS2, C2> {
  Disposable? _listener;

  late final List<C> _bufferedChanges = <C>[];

  Current get current;

  Self get source;

  C2? applyAction(final U action);

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

  void transformChange(
    final Current state,
    final C change,
    final Emitter<U> updater,
  );

  Future<void> _cancelListener() async {
    await _listener?.dispose();
    _listener = null;
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final C change in _bufferedChanges) {
        transformChange(
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

    transformChange(
      current,
      source.asChange(source.value),
      (final U action) {
        applyAction(action);
      },
    );

    _listener = source.listen(
      onChange: (final Self _) {
        final CS value = source.value;
        final C change = source.lastChange(value);
        if (state == ObservableState.inactive) {
          // store changes to apply when active
          _bufferedChanges.add(change);
          return;
        }

        transformChange(
          current,
          change,
          (final U action) {
            applyAction(action);
          },
        );
      },
    );
  }
}
