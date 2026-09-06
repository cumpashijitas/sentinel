/// Base type for all Sentinel-specific exceptions.
///
/// Feature code should catch and translate low-level exceptions (from
/// Supabase, sensors, etc.) into one of these so the presentation layer only
/// ever has to handle a small, predictable set of failure types.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-readable message, safe to show in the UI.
  final String message;

  /// The original error that caused this exception, if any. Useful for
  /// logging without leaking implementation details to the UI.
  final Object? cause;

  @override
  String toString() => message;
}

/// Thrown when required build-time configuration (Supabase URL/key, etc.)
/// is missing or invalid. See [core/config/app_config.dart].
final class ConfigurationException extends AppException {
  const ConfigurationException(super.message, {super.cause});
}

/// Thrown by the auth feature for sign-in/sign-up/sign-out failures.
final class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

/// Thrown by straightforward table-backed CRUD features (profile,
/// vehicles, emergency contacts, ...) for read/write failures — typically
/// an RLS rejection or a "row not found".
///
/// Shared across features rather than one exception type per feature: for
/// plain `select`/`update`/`insert` against a single RLS-protected table,
/// the failure modes and the translation logic are identical, so a
/// per-feature subclass would only duplicate this class under a different
/// name. Features whose failures carry real domain-specific meaning (e.g.
/// groups: "invalid invite code", "owner can't leave") should still get
/// their own exception type when that lands.
final class DataException extends AppException {
  const DataException(super.message, {super.cause});
}

/// Thrown by [ApiClient] (`core/network/api_client.dart`) when a request to
/// the Sentinel backend (`back/`) fails — a non-2xx response, a network
/// error, or a body that doesn't decode as expected. Feature repositories
/// catch this (the same way they used to catch `PostgrestException`) and
/// translate it into a [DataException] with a user-facing message.
final class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode, super.cause});

  /// HTTP status code, when the failure came from a response (as opposed to
  /// e.g. a connection error, where this is `null`).
  final int? statusCode;
}
