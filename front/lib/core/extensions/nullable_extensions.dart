/// Small null-safe pipe used when mapping optional Postgrest columns
/// (`String?` timestamps, mostly) into typed values without a verbose
/// `value == null ? null : f(value)` at every call site.
extension NullableLet<T> on T? {
  /// `x.let(f)` is `x == null ? null : f(x)`.
  R? let<R>(R Function(T value) f) {
    final value = this;
    return value == null ? null : f(value);
  }
}
