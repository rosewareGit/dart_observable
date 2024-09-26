import '../../../../dart_observable.dart';
import '../../rx/operators/_base_switch_map.dart';
import '../_base.dart';

mixin BaseSwitchMapChangeOperator<
    Result extends Observable<CS2>, //
    CS extends CollectionState<C>,
    C,
    CS2 extends CollectionState<C2>,
    C2> on RxCollectionBase<C2, CS2>, BaseSwitchMapOperator<Result, CS, CS2> {
  bool _firstMap = true;

  @override
  Result? Function(CS value) get mapper {
    return (final CS value) {
      final C change;
      if (_firstMap) {
        _firstMap = false;
        change = value.asChange();
      } else {
        change = value.lastChange;
      }

      return mapChange(change);
    };
  }

  Result? Function(C value) get mapChange;
}
