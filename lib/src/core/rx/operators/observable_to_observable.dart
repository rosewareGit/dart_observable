import '../../../../dart_observable.dart';
import 'observable_to_observable/switch_map.dart';
import 'observable_to_observable/transform.dart';

mixin OperatorsObservableToObservable<T> implements Observable<T> {
  @override
  Observable<T?> filter(final bool Function(T value) predicate) {
    return transform<T?>(
      initialProvider: (final T value) {
        if (predicate(value)) {
          return value;
        } else {
          return null;
        }
      },
      onChanged: (
        final T value,
        final Emitter<T?> emitter,
      ) {
        if (predicate(value)) {
          emitter(value);
        }
      },
    );
  }

  @override
  Observable<T2> map<T2>(final T2 Function(T value) onChanged) {
    return transform(
      initialProvider: (final T value) {
        return onChanged(value);
      },
      onChanged: (
        final T value,
        final Emitter<T2> emitter,
      ) {
        emitter(onChanged(value));
      },
    );
  }

  @override
  Observable<T2> switchMap<T2>(
    final Observable<T2> Function(T value) mapper,
  ) {
    return OperatorSwitchMap<T, T2>(
      source: this,
      mapper: mapper,
    );
  }

  @override
  Observable<T2> transform<T2>({
    required final T2 Function(T value) initialProvider,
    required final void Function(T value, Emitter<T2> emitter) onChanged,
  }) {
    return OperatorTransform<T, T2>(
      initialProvider(value),
      source: this,
      handler: onChanged,
    );
  }
}
