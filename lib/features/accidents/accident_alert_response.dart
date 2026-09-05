import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logging/app_logger.dart';
import 'data/datasources/accident_event_remote_datasource.dart';
import 'data/datasources/local_accident_alert_notifier.dart';
import 'data/repositories/accident_event_repository_impl.dart';

/// Wires up "Estoy bien" notification-tap handling for the **main UI**
/// engine — called once from `bootstrap()`. See
/// `docs/accident_detection.md` for the full picture; this doc comment
/// covers why it exists as a *second*, independent registration alongside
/// the one `RideBackgroundService`'s own engine does in
/// `lib/background/ride_background_main.dart`.
///
/// `flutter_local_notifications` on Android routes a tapped action back
/// through the app's launcher Activity — confirmed live on-device during
/// Fase 7's E2E pass: tapping "Estoy bien" brought `MainActivity` to the
/// front via a `SELECT_NOTIFICATION` intent, regardless of which engine
/// originally called `initialize`/`showAlert`. A callback registered only
/// in the background engine (the original design) never fires; that
/// engine keeps its own registration purely so the *native Android* side
/// has a callback to invoke at all (required by the plugin's `initialize`
/// call), not because it expects to receive the response.
///
/// This handler is deliberately self-contained: it only calls
/// `AccidentEventRepository.cancel(id)` directly against Supabase, never
/// anything on `RideBackgroundService`'s in-memory countdown state — this
/// engine has no reference to that other isolate. If the background
/// engine's own countdown timer fires *after* this already resolved the
/// row, its `confirm()` call becomes a harmless no-op: the RLS policy on
/// `accident_events` only allows that update while the row is still
/// `candidate`, so a stale confirm silently matches zero rows instead of
/// overwriting the cancellation.
Future<void> initializeAccidentAlertResponseHandling() async {
  final repository = AccidentEventRepositoryImpl(
    SupabaseAccidentEventRemoteDataSource(Supabase.instance.client),
  );

  await LocalAccidentAlertNotifier().initialize(
    onConfirmedOk: (accidentEventId) {
      unawaited(
        repository.cancel(accidentEventId).catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          AppLogger.error(
            'No se pudo cancelar el evento de accidente desde la notificación',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    },
  );
}
