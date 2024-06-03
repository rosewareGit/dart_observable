import '../_impl.dart';

class FutureObservable<T> extends RxImpl<T> {
  final Future<T>? future;
  final Future<T> Function()? futureProvider;

  FutureObservable({
    required final T initial,
    this.future,
    this.futureProvider,
    final bool lazy = true,
    final bool distinct = true,
  }) : super(
          initial,
          distinct: distinct,
        );

  @override
  void onActive() {
    super.onActive();
    if (future == null && futureProvider == null) {
      dispose();
      return;
    }
    if (future != null) {
      _handleFuture(future!);
    }
    if (futureProvider != null) {
      _handleFuture(futureProvider!());
    }
  }

  void _handleFuture(final Future<T> future) {
    future.then(
      (final T value) {
        if (disposed == false) {
          this.value = value;
          dispose();
        }
      },
      onError: (final dynamic error, final StackTrace stack) {
        if (disposed == false) {
          dispatchError(error: error, stack: stack);
          dispose();
        }
      },
    );
  }
}
