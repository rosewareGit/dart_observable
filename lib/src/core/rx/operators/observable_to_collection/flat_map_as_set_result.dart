// TODO: Implement this
// import 'dart:async';
//
// import '../../../../../dart_observable.dart';
// import '../../../collections/set/failure.dart';
//
// class OperatorFlatMapAsSetResult<T, T2, F> extends RxSetResultImpl<T2, F> {
//   final ObservableSetResult<T2, F> Function(
//     Observable<T> source,
//     Set<T2> Function(Iterable<T2>? items)? factory,
//   ) mapper;
//   final Observable<T> source;
//
//   Disposable? _intermediateListener;
//   Disposable? _listener;
//   ObservableSetResult<T2, F>? _activeRxIntermediate;
//   final FactorySet<T2>? factory;
//
//   OperatorFlatMapAsSetResult({
//     required this.source,
//     required this.mapper,
//     this.factory,
//   }) : super.state(
//           state: mapper(source, factory).value,
//           factory: factory,
//         );
//
//   @override
//   void onActive() {
//     super.onActive();
//     _initListener();
//   }
//
//   @override
//   Future<void> onInactive() async {
//     await super.onInactive();
//     await _cancelListener();
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     source.addDisposeWorker(() => dispose());
//   }
//
//   Future<void> _cancelListener() async {
//     _listener?.dispose();
//     _intermediateListener?.dispose();
//     _listener = null;
//     _intermediateListener = null;
//     _activeRxIntermediate = null;
//   }
//
//   void _initListener() {
//     if (_listener != null) {
//       return;
//     }
//
//     final ObservableSetResult<T2, F> rxIntermediate = mapper(source, factory);
//     _activeRxIntermediate = rxIntermediate;
//
//     final ObservableSetResultChange<T2, F> initialChange = rxIntermediate.value.asChange();
//     applyAction(initialChange.asAction);
//
//     _intermediateListener = rxIntermediate.listen(
//       onChange: (final Observable<ObservableSetResultState<T2, F>> source) {
//         final ObservableSetResultChange<T2, F> change = source.value.lastChange;
//         applyAction(change.asAction);
//       },
//     );
//
//     _listener = source.listen(
//       onChange: (final Observable<T> source) {
//         final ObservableSetResult<T2, F> rxIntermediate = mapper(source, factory);
//         if (_activeRxIntermediate != rxIntermediate) {
//           value = rxIntermediate.value;
//           _intermediateListener?.dispose();
//           _intermediateListener = rxIntermediate.listen(
//             onChange: (final Observable<ObservableSetResultState<T2, F>> source) {
//               final ObservableSetResultChange<T2, F> change = source.value.lastChange;
//               applyAction(change.asAction);
//             },
//           );
//           _activeRxIntermediate = rxIntermediate;
//         }
//       },
//     );
//   }
// }
