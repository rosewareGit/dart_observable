import '../../../../dart_observable.dart';
import '../../../api/change_tracking_observable.dart';

class BaseCollectionTransformOperatorProxy<
    Self extends ChangeTrackingObservable<Self, CS, C>,
    CS, // Collection state for this
    CS2, // Collection state for the transformed
    C,
    C2> {
  Disposable? _listener;

  late final List<C> _bufferedChanges = <C>[];

  final Self source;
  final ChangeTrackingObservable<dynamic, dynamic, dynamic> _current;
  final Function(C change) transformChange;

  BaseCollectionTransformOperatorProxy({
    required final ChangeTrackingObservable<dynamic, dynamic, dynamic> current,
    required this.source,
    required this.transformChange,
  }) : _current = current;

  void init() {
    final Disposable activeListener = _current.onActivityChanged(
      onActive: (final _) {
        _initListener();
      },
    );

    source.addDisposeWorker(() async {
      await activeListener.dispose();
      final Disposable? changeListener = _listener;
      if (changeListener != null) {
        await changeListener.dispose();
        _listener = null;
      }
      return _current.dispose();
    });
  }

  void _initListener() {
    if (_listener != null) {
      // apply buffered changes
      for (final C change in _bufferedChanges) {
        transformChange(change);
      }
      _bufferedChanges.clear();
      return;
    }

    transformChange(source.asChange(source.value));

    _listener = source.listen(
      onChange: (final Self _) {
        final CS value = source.value;
        final C change = source.lastChange(value);
        if (_current.state == ObservableState.inactive) {
          // store changes to apply when active
          _bufferedChanges.add(change);
          return;
        }

        transformChange(change);
      },
    );
  }
}
