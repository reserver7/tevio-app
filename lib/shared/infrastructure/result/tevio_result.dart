import 'tevio_failure.dart';

sealed class TevioResult<T> {
  const TevioResult();

  R when<R>({
    required R Function(T value) success,
    required R Function(TevioFailure failure) failure,
  }) {
    return switch (this) {
      TevioSuccess(:final value) => success(value),
      TevioFailureResult(:final error) => failure(error),
    };
  }
}

class TevioSuccess<T> extends TevioResult<T> {
  const TevioSuccess(this.value);

  final T value;
}

class TevioFailureResult<T> extends TevioResult<T> {
  const TevioFailureResult(this.error);

  final TevioFailure error;
}
