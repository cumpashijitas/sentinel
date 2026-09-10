import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../accidents/domain/entities/accident_event.dart';
import '../../../accidents/presentation/controllers/accident_event_providers.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../emergency_shares/domain/entities/emergency_share.dart';
import '../../../emergency_shares/presentation/controllers/emergency_share_providers.dart';
import '../../../rides/domain/entities/ride_history_entry.dart';
import '../../../rides/presentation/controllers/ride_sessions_controller.dart';
import '../../domain/entities/ride_statistics.dart';
import '../../domain/entities/route_history_entry.dart';
import '../../domain/services/ride_statistics_calculator.dart';

part 'history_controller.g.dart';

/// Every `finished` ride the signed-in user participated in, newest first.
@riverpod
Future<List<RideHistoryEntry>> rideHistory(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  return ref.watch(rideSessionRepositoryProvider).fetchHistory(user.id);
}

/// Every share ("viaje individual") the signed-in user has ended, newest
/// first — pedido explícito en vivo, junto a [rideHistoryProvider] para
/// las de grupo.
@riverpod
Future<List<EmergencyShare>> shareHistory(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  return ref.watch(emergencyShareRepositoryProvider).fetchHistory();
}

/// [rideHistoryProvider] and [shareHistoryProvider] merged into a single
/// chronological feed — what the "Viajes" tab actually renders. See
/// [RouteHistoryMerger].
@riverpod
Future<List<RouteHistoryEntry>> routeHistory(Ref ref) async {
  final rides = await ref.watch(rideHistoryProvider.future);
  final shares = await ref.watch(shareHistoryProvider.future);
  return RouteHistoryMerger.merge(rides: rides, shares: shares);
}

/// Every accident event the signed-in user has ever reported, any status,
/// newest first.
@riverpod
Future<List<AccidentEvent>> accidentHistory(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  return ref.watch(accidentEventRepositoryProvider).fetchMine(user.id);
}

/// A single accident event by id — used by the history list's detail page,
/// reached either from [accidentHistoryProvider] or a direct
/// `/accidents/:id` link.
@riverpod
Future<AccidentEvent> accidentDetail(Ref ref, String accidentId) {
  return ref.watch(accidentEventRepositoryProvider).fetchById(accidentId);
}

/// Derived from [rideHistoryProvider]/[shareHistoryProvider]/
/// [accidentHistoryProvider] — see [RideStatisticsCalculator] for why this
/// isn't its own datasource call.
@riverpod
Future<RideStatistics> rideStatistics(Ref ref) async {
  final rides = await ref.watch(rideHistoryProvider.future);
  final shares = await ref.watch(shareHistoryProvider.future);
  final accidents = await ref.watch(accidentHistoryProvider.future);
  return RideStatisticsCalculator.compute(
    rides: rides,
    shares: shares,
    accidents: accidents,
  );
}
