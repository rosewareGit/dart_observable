import '../../../../dart_observable.dart';
import '../../rx/_impl.dart';

mixin BaseCollectionFlatMapOperator<
    E, //
    E2,
    C,
    T extends CollectionState<E, C>,
    C2,
    T2 extends CollectionState<E2, C2>,
    S extends ObservableCollection<E2, C2, T2>,
    U extends ObservableCollectionUpdateAction> on RxImpl<T2> {}
