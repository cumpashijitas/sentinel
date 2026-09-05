// Shared fakes for Fase 9 (history) tests — not itself a test suite
// (no `main()`), so `flutter test` never picks it up directly.
import 'package:sentinel_v2/features/accidents/domain/entities/accident_event.dart';
import 'package:sentinel_v2/features/accidents/domain/entities/motion_sample.dart';
import 'package:sentinel_v2/features/accidents/domain/repositories/accident_event_repository.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';
import 'package:sentinel_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_history_entry.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/repositories/ride_session_repository.dart';

const currentTestUser = AppUser(id: 'u1', email: 'rider1@sentinel.dev');

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  AppUser? userOverride = currentTestUser;

  @override
  AppUser? get currentUser => userOverride;

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(userOverride).asBroadcastStream();

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AppUser> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

class FakeRideSessionRepository implements RideSessionRepository {
  List<RideHistoryEntry> historyToReturn = [];
  String? lastRequestedUserId;

  @override
  Future<List<RideHistoryEntry>> fetchHistory(String userId) async {
    lastRequestedUserId = userId;
    return historyToReturn;
  }

  @override
  Future<RideSession?> fetchActiveSession(String groupId) =>
      throw UnimplementedError();

  @override
  Future<RideSession> fetchSession(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<List<RideSessionParticipant>> fetchParticipants(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<RideSession> startSession({required String groupId, String? name}) =>
      throw UnimplementedError();

  @override
  Future<RideSession> finishSession(String sessionId) =>
      throw UnimplementedError();
}

class FakeAccidentEventRepository implements AccidentEventRepository {
  List<AccidentEvent> historyToReturn = [];
  AccidentEvent? byIdToReturn;

  @override
  Future<List<AccidentEvent>> fetchMine(String userId) async => historyToReturn;

  @override
  Future<AccidentEvent> fetchById(String accidentEventId) async =>
      byIdToReturn!;

  @override
  Future<AccidentEvent> reportCandidate({
    required String userId,
    required String? sessionId,
    required double impactMps2,
    double? gyroRadS,
    double? gForce,
    double? confidenceScore,
    double? latitude,
    double? longitude,
    required MotionSample sample,
  }) => throw UnimplementedError();

  @override
  Future<void> cancel(String accidentEventId) => throw UnimplementedError();

  @override
  Future<void> confirm(String accidentEventId) => throw UnimplementedError();
}
