import '../_impl.dart';

class FutureObservableN<T> extends RxnImpl<T> {
  final Future<T?>? future;
  final Future<T?> Function()? futureProvider;

  FutureObservableN({
    this.future,
    this.futureProvider,
    final bool distinct = true,
  }) : super(
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

  void _handleFuture(final Future<T?> future) {
    future.then(
      (final T? value) {
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
