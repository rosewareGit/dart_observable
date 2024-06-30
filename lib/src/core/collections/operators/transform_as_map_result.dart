part of '../map/result.dart';

class OperatorCollectionsTransformAsMapResult<E, C, T extends CollectionState<E, C>, K, V, F>
    extends RxMapResultImpl<K, V, F>
    with
        BaseCollectionTransformOperator<
            E, //
            K,
            C,
            T,
            ObservableMapResultChange<K, V, F>,
            ObservableMapResultState<K, V, F>,
            ObservableMapResult<K, V, F>,
            ObservableMapResultUpdateAction<K, V, F>> {
  @override
  final ObservableCollection<E, C, T> source;

  final void Function(
    ObservableMapResult<K, V, F> state,
    C change,
    Emitter<ObservableMapResultUpdateAction<K, V, F>> updater,
  ) transformFn;

  OperatorCollectionsTransformAsMapResult({
    required this.source,
    required this.transformFn,
    final Map<K, V> Function(Map<K, V>? items)? factory,
  }) : super(factory: factory);

  @override
  ObservableMapResult<K, V, F> get current => this;

  @override
  void transformChange(
    final ObservableMapResult<K, V, F> state,
    final C change,
    final Emitter<ObservableMapResultUpdateAction<K, V, F>> updater,
  ) {
    transformFn(state, change, updater);
  }
}
