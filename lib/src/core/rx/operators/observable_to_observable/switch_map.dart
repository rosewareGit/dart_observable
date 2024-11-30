import '../../../../../dart_observable.dart';
import '../../_impl.dart';
import '../_base_switch_map.dart';

class OperatorSwitchMap<T, T2> extends RxImpl<T2> with BaseSwitchMapOperator<Observable<T2>, T, T2> {
  @override
  final Observable<T2> Function(T value) mapper;
  @override
  final Observable<T> source;

  OperatorSwitchMap({
    required this.source,
    required this.mapper,
  }) : super(mapper(source.value).value);

  @override
  void onIntermediateUpdated(final Observable<T2> intermediate, final T2 value) {
    this.value = value;
  }
}
