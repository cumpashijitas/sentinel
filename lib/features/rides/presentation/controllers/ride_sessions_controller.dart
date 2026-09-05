import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/supabase_providers.dart';
import '../../data/datasources/ride_session_remote_datasource.dart';
import '../../data/repositories/ride_session_repository_impl.dart';
import '../../domain/entities/ride_session.dart';
import '../../domain/entities/ride_session_participant.dart';
import '../../domain/repositories/ride_session_repository.dart';

part 'ride_sessions_controller.g.dart';

@riverpod
RideSessionRemoteDataSource rideSessionRemoteDataSource(Ref ref) {
  return SupabaseRideSessionRemoteDataSource(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
RideSessionRepository rideSessionRepository(Ref ref) {
  return RideSessionRepositoryImpl(
    ref.watch(rideSessionRemoteDataSourceProvider),
  );
}

/// The group's current `waiting`/`active` session, or `null`. Drives
/// whether `GroupDetailPage` shows "start a ride" or "open the active
/// ride". Invalidated by [RideSessionActionsController] after starting or
/// finishing a session.
@riverpod
Future<RideSession?> activeSession(Ref ref, String groupId) {
  return ref.watch(rideSessionRepositoryProvider).fetchActiveSession(groupId);
}

/// A single session's details, by id.
@riverpod
Future<RideSession> rideSession(Ref ref, String sessionId) {
  return ref.watch(rideSessionRepositoryProvider).fetchSession(sessionId);
}

/// The roster of a single session, by id.
@riverpod
Future<List<RideSessionParticipant>> rideParticipants(
  Ref ref,
  String sessionId,
) {
  return ref.watch(rideSessionRepositoryProvider).fetchParticipants(sessionId);
}

/// Drives start/finish. Same shape as [GroupActionsController]: the state
/// is only the action's own loading/error/success, but each method also
/// *returns* the resulting session so the page can navigate/refresh
/// without a second round trip through a provider.
@riverpod
class RideSessionActionsController extends _$RideSessionActionsController {
  @override
  FutureOr<void> build() {}

  Future<RideSession?> start({required String groupId, String? name}) async {
    state = const AsyncLoading();
    RideSession? started;
    state = await AsyncValue.guard(() async {
      started = await ref
          .read(rideSessionRepositoryProvider)
          .startSession(groupId: groupId, name: name);
      ref.invalidate(activeSessionProvider(groupId));
    });
    return state.hasError ? null : started;
  }

  Future<RideSession?> finish({
    required String sessionId,
    required String groupId,
  }) async {
    state = const AsyncLoading();
    RideSession? finished;
    state = await AsyncValue.guard(() async {
      finished = await ref
          .read(rideSessionRepositoryProvider)
          .finishSession(sessionId);
      ref.invalidate(activeSessionProvider(groupId));
      ref.invalidate(rideSessionProvider(sessionId));
      ref.invalidate(rideParticipantsProvider(sessionId));
    });
    return state.hasError ? null : finished;
  }
}
