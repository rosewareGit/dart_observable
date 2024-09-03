import '../../../../dart_observable.dart';
import '../../rx/operators/_base_transform_proxy.dart';

class BaseCollectionTransformOperatorProxy<
    T extends CollectionState<C>, // Collection state for this
    T2 extends CollectionState<C2>, // Collection state for the transformed
    C,
    C2> {
  bool _initialChange = true;

  late final BaseTransformOperatorProxy<T, T2> _valueProxy = BaseTransformOperatorProxy<T, T2>(
    current: _current,
    source: source,
    transform: (final T value) {
      if (_initialChange) {
        transformChange(value.asChange());
        _initialChange = false;
      } else {
        transformChange(value.lastChange);
      }
    },
  );
  final Observable<T> source;
  final Observable<T2> _current;
  final Function(C change) transformChange;

  BaseCollectionTransformOperatorProxy({
    required final Observable<T2> current,
    required this.source,
    required this.transformChange,
  }) : _current = current;

  void init() {
    _valueProxy.init();
  }
}
