import '../../../../dart_observable.dart';
import 'observable_to_observable/flat_map.dart';
import 'observable_to_observable/transform.dart';

mixin OperatorsObservableToObservable<T> implements Observable<T> {
  @override
  Observable<T?> filter(final bool Function(Observable<T> source) predicate) {
    return transform<T?>(
      initialProvider: (final Observable<T> source) {
        if (predicate(source)) {
          return value;
        } else {
          return null;
        }
      },
      onChanged: (
        final Observable<T> source,
        final Emitter<T?> emitter,
      ) {
        if (predicate(source)) {
          emitter(source.value);
        }
      },
    );
  }

  @override
  Observable<T2> flatMap<T2>(
    final Observable<T2> Function(Observable<T> source) mapper,
  ) {
    return OperatorFlatMap<T, T2>(
      source: this,
      mapper: mapper,
    );
  }

  @override
  Observable<T2> map<T2>(final T2 Function(Observable<T> source) onChanged) {
    return transform(
      initialProvider: (final Observable<T> source) {
        return onChanged(source);
      },
      onChanged: (
        final Observable<T> source,
        final Emitter<T2> emitter,
      ) {
        emitter(onChanged(source));
      },
    );
  }

  @override
  Observable<T2> transform<T2>({
    required final T2 Function(Observable<T> source) initialProvider,
    required final void Function(Observable<T> source, Emitter<T2> emitter) onChanged,
  }) {
    return OperatorTransform<T, T2>(
      initialProvider(this),
      source: this,
      handler: onChanged,
    );
  }
}
