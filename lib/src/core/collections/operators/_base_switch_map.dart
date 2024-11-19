import '../../../../dart_observable.dart';
import '../../rx/operators/_base_switch_map.dart';
import '../_base.dart';

mixin BaseSwitchMapChangeOperator<
    Result extends Observable<T2>, //
    T,
    C,
    T2,
    C2> on RxCollectionBase<T2, C2>, BaseSwitchMapOperator<Result, T, T2> {
  bool _firstMap = true;

  @override
  ObservableCollection<T, C> get source;

  Result? _mapper(final T value) {
    final C change;
    if (_firstMap) {
      _firstMap = false;
      change = source.currentStateAsChange;
    } else {
      change = source.change;
    }

    return mapChange(change);
  }

  @override
  late final Result? Function(T value) mapper = _mapper;

  Result? Function(C value) get mapChange;
}
