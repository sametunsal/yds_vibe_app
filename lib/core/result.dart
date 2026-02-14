sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => this is Success<T> ? (this as Success<T>).value : null;
  String? get error => this is Failure<T> ? (this as Failure<T>).message : null;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
