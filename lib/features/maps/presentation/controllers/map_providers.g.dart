// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Built once from [AppConfig] (`--dart-define-from-file`) — see
/// `MapTileConfig`'s own doc comment for why every field here matters,
/// especially `offlineAllowed`.

@ProviderFor(mapTileConfig)
final mapTileConfigProvider = MapTileConfigProvider._();

/// Built once from [AppConfig] (`--dart-define-from-file`) — see
/// `MapTileConfig`'s own doc comment for why every field here matters,
/// especially `offlineAllowed`.

final class MapTileConfigProvider
    extends $FunctionalProvider<MapTileConfig, MapTileConfig, MapTileConfig>
    with $Provider<MapTileConfig> {
  /// Built once from [AppConfig] (`--dart-define-from-file`) — see
  /// `MapTileConfig`'s own doc comment for why every field here matters,
  /// especially `offlineAllowed`.
  MapTileConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTileConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTileConfigHash();

  @$internal
  @override
  $ProviderElement<MapTileConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapTileConfig create(Ref ref) {
    return mapTileConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapTileConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapTileConfig>(value),
    );
  }
}

String _$mapTileConfigHash() => r'5a88d8b5c6b1867725996ad3c8aae0fc2516bc99';

/// `keepAlive`: cheap to construct (no I/O, no native handles of its own —
/// those live in the `Widget`/`MapController` it hands out per screen),
/// but there's no reason to let it churn either.

@ProviderFor(mapService)
final mapServiceProvider = MapServiceProvider._();

/// `keepAlive`: cheap to construct (no I/O, no native handles of its own —
/// those live in the `Widget`/`MapController` it hands out per screen),
/// but there's no reason to let it churn either.

final class MapServiceProvider
    extends $FunctionalProvider<MapService, MapService, MapService>
    with $Provider<MapService> {
  /// `keepAlive`: cheap to construct (no I/O, no native handles of its own —
  /// those live in the `Widget`/`MapController` it hands out per screen),
  /// but there's no reason to let it churn either.
  MapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapServiceHash();

  @$internal
  @override
  $ProviderElement<MapService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapService create(Ref ref) {
    return mapService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapService>(value),
    );
  }
}

String _$mapServiceHash() => r'63dda04ef577e3aa9fc36b78d60163a00cf57622';
