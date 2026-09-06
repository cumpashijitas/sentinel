// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(devicePushTokenRemoteDataSource)
final devicePushTokenRemoteDataSourceProvider =
    DevicePushTokenRemoteDataSourceProvider._();

final class DevicePushTokenRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          DevicePushTokenRemoteDataSource,
          DevicePushTokenRemoteDataSource,
          DevicePushTokenRemoteDataSource
        >
    with $Provider<DevicePushTokenRemoteDataSource> {
  DevicePushTokenRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devicePushTokenRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devicePushTokenRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<DevicePushTokenRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DevicePushTokenRemoteDataSource create(Ref ref) {
    return devicePushTokenRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevicePushTokenRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevicePushTokenRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$devicePushTokenRemoteDataSourceHash() =>
    r'58717a657685397a5b3a8ecb4ecb7612f3d92b6b';

@ProviderFor(devicePushTokenRepository)
final devicePushTokenRepositoryProvider = DevicePushTokenRepositoryProvider._();

final class DevicePushTokenRepositoryProvider
    extends
        $FunctionalProvider<
          DevicePushTokenRepository,
          DevicePushTokenRepository,
          DevicePushTokenRepository
        >
    with $Provider<DevicePushTokenRepository> {
  DevicePushTokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devicePushTokenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devicePushTokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<DevicePushTokenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DevicePushTokenRepository create(Ref ref) {
    return devicePushTokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevicePushTokenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevicePushTokenRepository>(value),
    );
  }
}

String _$devicePushTokenRepositoryHash() =>
    r'42b70a99c0995c4be6d5f877f40b17240b37e5b2';

/// See `UnavailablePushTokenSource`'s doc comment for why this is the only
/// implementation today, on both platforms.

@ProviderFor(pushTokenSource)
final pushTokenSourceProvider = PushTokenSourceProvider._();

/// See `UnavailablePushTokenSource`'s doc comment for why this is the only
/// implementation today, on both platforms.

final class PushTokenSourceProvider
    extends
        $FunctionalProvider<PushTokenSource, PushTokenSource, PushTokenSource>
    with $Provider<PushTokenSource> {
  /// See `UnavailablePushTokenSource`'s doc comment for why this is the only
  /// implementation today, on both platforms.
  PushTokenSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenSourceHash();

  @$internal
  @override
  $ProviderElement<PushTokenSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushTokenSource create(Ref ref) {
    return pushTokenSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushTokenSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushTokenSource>(value),
    );
  }
}

String _$pushTokenSourceHash() => r'67d842b9d8ec0195cd2ab6e3b900eec5d58c691c';

@ProviderFor(pushTokenRegistrar)
final pushTokenRegistrarProvider = PushTokenRegistrarProvider._();

final class PushTokenRegistrarProvider
    extends
        $FunctionalProvider<
          PushTokenRegistrar,
          PushTokenRegistrar,
          PushTokenRegistrar
        >
    with $Provider<PushTokenRegistrar> {
  PushTokenRegistrarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenRegistrarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenRegistrarHash();

  @$internal
  @override
  $ProviderElement<PushTokenRegistrar> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushTokenRegistrar create(Ref ref) {
    return pushTokenRegistrar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushTokenRegistrar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushTokenRegistrar>(value),
    );
  }
}

String _$pushTokenRegistrarHash() =>
    r'71add1ab851857bf1f215e0540b7d4d48c086688';

/// Drives [PushTokenRegistrar] off the app's actual auth session — watch
/// this once from [SentinelApp] (same idiom as `goRouterProvider`) to keep
/// it alive for the app's lifetime. Android-only: push notifications are an
/// Android-only capability (`PlatformCapabilities.supportsDeviceNotifications`),
/// so this never even reads the auth session on Web.
///
/// Reads `AuthRepository.authStateChanges` directly (the same stream
/// `authStateChangesProvider` itself wraps — see `auth_controller.dart`)
/// rather than depending on that provider's own stream, so this doesn't
/// couple to which stream-access API a given `riverpod_generator` version
/// exposes on a generated provider.
///
/// A `Stream<void>` rather than a plain `Future<void> build()` because it
/// must keep reacting for as long as the app runs, not just once — every
/// sign-in/sign-out for the rest of the session, not only the first one
/// observed at startup.

@ProviderFor(pushTokenRegistration)
final pushTokenRegistrationProvider = PushTokenRegistrationProvider._();

/// Drives [PushTokenRegistrar] off the app's actual auth session — watch
/// this once from [SentinelApp] (same idiom as `goRouterProvider`) to keep
/// it alive for the app's lifetime. Android-only: push notifications are an
/// Android-only capability (`PlatformCapabilities.supportsDeviceNotifications`),
/// so this never even reads the auth session on Web.
///
/// Reads `AuthRepository.authStateChanges` directly (the same stream
/// `authStateChangesProvider` itself wraps — see `auth_controller.dart`)
/// rather than depending on that provider's own stream, so this doesn't
/// couple to which stream-access API a given `riverpod_generator` version
/// exposes on a generated provider.
///
/// A `Stream<void>` rather than a plain `Future<void> build()` because it
/// must keep reacting for as long as the app runs, not just once — every
/// sign-in/sign-out for the rest of the session, not only the first one
/// observed at startup.

final class PushTokenRegistrationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, Stream<void>>
    with $FutureModifier<void>, $StreamProvider<void> {
  /// Drives [PushTokenRegistrar] off the app's actual auth session — watch
  /// this once from [SentinelApp] (same idiom as `goRouterProvider`) to keep
  /// it alive for the app's lifetime. Android-only: push notifications are an
  /// Android-only capability (`PlatformCapabilities.supportsDeviceNotifications`),
  /// so this never even reads the auth session on Web.
  ///
  /// Reads `AuthRepository.authStateChanges` directly (the same stream
  /// `authStateChangesProvider` itself wraps — see `auth_controller.dart`)
  /// rather than depending on that provider's own stream, so this doesn't
  /// couple to which stream-access API a given `riverpod_generator` version
  /// exposes on a generated provider.
  ///
  /// A `Stream<void>` rather than a plain `Future<void> build()` because it
  /// must keep reacting for as long as the app runs, not just once — every
  /// sign-in/sign-out for the rest of the session, not only the first one
  /// observed at startup.
  PushTokenRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenRegistrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenRegistrationHash();

  @$internal
  @override
  $StreamProviderElement<void> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<void> create(Ref ref) {
    return pushTokenRegistration(ref);
  }
}

String _$pushTokenRegistrationHash() =>
    r'88ae31e5fb1fd8df7e86c6f71a365910646c55aa';
