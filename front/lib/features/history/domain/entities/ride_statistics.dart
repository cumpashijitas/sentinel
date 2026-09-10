import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_statistics.freezed.dart';

/// Basic, derived (never persisted) usage summary for the signed-in rider —
/// Fase 9. Computed client-side by `RideStatisticsCalculator` from
/// [RideHistoryEntry]/`AccidentEvent` lists that are already being fetched
/// for the history screens, rather than a dedicated RPC — see that class's
/// doc comment for why.
@freezed
abstract class RideStatistics with _$RideStatistics {
  const factory RideStatistics({
    /// Viajes de grupo terminados — no incluye rutas individuales, ver
    /// [totalIndividualRides] para esas.
    required int totalRides,
    required Duration totalRideDuration,

    /// Shares personales terminados ("viajes individuales") — pedido
    /// explícito en vivo junto a las rutas de grupo.
    required int totalIndividualRides,
    required Duration totalIndividualRideDuration,
    required int totalAccidents,
    DateTime? lastRideAt,
  }) = _RideStatistics;

  const RideStatistics._();

  /// Actividades totales, de grupo o individuales — la métrica que un
  /// rider realmente quiere ver de un vistazo, estilo Strava.
  int get totalActivities => totalRides + totalIndividualRides;
}
