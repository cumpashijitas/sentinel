import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import 'data/datasources/local_accident_alert_notifier.dart';

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
/// Pedido explícito en vivo, tras confirmar que el tap en sí ya llegaba:
/// en vez de resolver el evento en silencio desde acá (sin ninguna
/// pantalla propia, sin forma de pedir ayuda en vez de solo cancelar),
/// esto ahora **navega** a [AccidentConfirmationPage] — que es la que de
/// verdad llama a `cancel()`/`confirm()`, con las dos opciones separadas
/// ("Sí, estoy bien" / "Necesito ayuda") y su propia confirmación visual.
/// `goRouterProvider` es `keepAlive`, así que `container.read(...)` da la
/// misma instancia de `GoRouter` que `runApp()` termina usando — llamar
/// `.push(...)` acá funciona sin importar si `runApp()` ya corrió o no
/// (el estado de ubicación de go_router es independiente del árbol de
/// widgets; el `Navigator` lo sincroniza apenas se monta).
Future<void> initializeAccidentAlertResponseHandling(
  ProviderContainer container,
) async {
  await LocalAccidentAlertNotifier().initialize(
    onConfirmedOk: (accidentEventId) {
      container
          .read(goRouterProvider)
          .push(AppRoutes.accidentConfirmPath(accidentEventId));
    },
  );
}
