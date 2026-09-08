import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/datasources/device_push_token_remote_datasource.dart';
import '../../data/datasources/unavailable_push_token_source.dart';
import '../../data/repositories/device_push_token_repository_impl.dart';
import '../../domain/repositories/device_push_token_repository.dart';
import '../../domain/repositories/push_token_source.dart';
import '../../domain/services/push_token_registrar.dart';

part 'push_token_providers.g.dart';

@riverpod
DevicePushTokenRemoteDataSource devicePushTokenRemoteDataSource(Ref ref) {
  return HttpDevicePushTokenRemoteDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
DevicePushTokenRepository devicePushTokenRepository(Ref ref) {
  return DevicePushTokenRepositoryImpl(
    ref.watch(devicePushTokenRemoteDataSourceProvider),
  );
}

/// See `UnavailablePushTokenSource`'s doc comment for why this is the only
/// implementation today, on both platforms.
@riverpod
PushTokenSource pushTokenSource(Ref ref) => const UnavailablePushTokenSource();

@Riverpod(keepAlive: true)
PushTokenRegistrar pushTokenRegistrar(Ref ref) {
  final registrar = PushTokenRegistrar(
    repository: ref.watch(devicePushTokenRepositoryProvider),
    source: ref.watch(pushTokenSourceProvider),
  );
  ref.onDispose(registrar.dispose);
  return registrar;
}

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
@riverpod
Stream<void> pushTokenRegistration(Ref ref) async* {
  if (!PlatformCapabilities.isAndroid) return;

  final registrar = ref.watch(pushTokenRegistrarProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  await for (final user in authRepository.authStateChanges) {
    try {
      await registrar.onUserChanged(user?.id);
    } catch (error, stackTrace) {
      AppLogger.error(
        'No se pudo sincronizar el push token de este dispositivo',
        error: error,
        stackTrace: stackTrace,
      );
    }
    yield null;
  }
}
