// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Depends on [appConfigProvider] for `API_BASE_URL` and on [SessionStore]
/// for the bearer token — always reads the *current* token at request time
/// (never a stale one captured at provider creation).

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

/// Depends on [appConfigProvider] for `API_BASE_URL` and on [SessionStore]
/// for the bearer token — always reads the *current* token at request time
/// (never a stale one captured at provider creation).

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  /// Depends on [appConfigProvider] for `API_BASE_URL` and on [SessionStore]
  /// for the bearer token — always reads the *current* token at request time
  /// (never a stale one captured at provider creation).
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'3026f9da621d3da802dcabb414a272b16d514a52';
