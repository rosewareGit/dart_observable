import 'dart:async';

R? runGuarded<R>(
  final R? Function() block, {
  required final void Function(dynamic error, StackTrace stack) onError,
}) {
  return runZonedGuarded<R?>(
    () {
      try {
        return block();
      } catch (e, s) {
        onError(e, s);
        return null;
      }
    },
    (final Object error, final StackTrace stack) {
      onError(error, stack);
    },
    zoneSpecification: ZoneSpecification(
      handleUncaughtError: (
        final Zone self,
        final ZoneDelegate parent,
        final Zone zone,
        final Object error,
        final StackTrace stackTrace,
      ) {
        onError(error, stackTrace);
      },
    ),
  );
}
