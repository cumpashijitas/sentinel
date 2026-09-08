import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/location_fix.dart';
import '../../domain/repositories/live_location_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/location_tracker.dart';
import '../../domain/services/location_sampling_policy.dart';

class LocationRepositoryImpl implements LocationRepository {
  // Initializing formals on private fields: Dart still exposes these as
  // public named parameters at the call site (`tracker:`, not `_tracker:`)
  // — see `live_tracking_controller.dart`'s `LocationRepositoryImpl(...)`
  // call, which uses exactly those public names.
  LocationRepositoryImpl({
    required this._tracker,
    required this._liveLocationRepository,
    required this._authRepository,
    this._samplingPolicy = const LocationSamplingPolicy(),
  });

  final LocationTracker _tracker;
  final LiveLocationRepository _liveLocationRepository;
  final AuthRepository _authRepository;
  final LocationSamplingPolicy _samplingPolicy;

  StreamSubscription<LocationFix>? _subscription;
  String? _activeSessionId;
  LocationFix? _lastRecordedHistoryFix;

  @override
  bool get isSharing => _subscription != null;

  @override
  Future<void> startSharing(String sessionId) async {
    if (isSharing && _activeSessionId == sessionId) {
      return; // already sharing this session
    }
    await stopSharing(); // switch cleanly if a different session was active

    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      throw const DataException(
        'Debes iniciar sesión para compartir tu ubicación.',
      );
    }

    final granted = await _tracker.ensurePermission();
    if (!granted) {
      throw const DataException(
        'Sentinel necesita permiso de ubicación para compartir tu posición en el viaje.',
      );
    }

    _activeSessionId = sessionId;
    _lastRecordedHistoryFix = null;
    _subscription = _tracker.watchPosition().listen((fix) {
      unawaited(
        _liveLocationRepository
            .upsertMyLocation(sessionId: sessionId, userId: userId, fix: fix)
            .catchError((Object error, StackTrace stackTrace) {
              AppLogger.error(
                'Failed to upsert live location',
                error: error,
                stackTrace: stackTrace,
              );
            }),
      );

      if (_samplingPolicy.shouldRecord(
        lastRecorded: _lastRecordedHistoryFix,
        current: fix,
      )) {
        _lastRecordedHistoryFix = fix;
        unawaited(
          _liveLocationRepository
              .recordHistory(sessionId: sessionId, userId: userId, fix: fix)
              .catchError((Object error, StackTrace stackTrace) {
                AppLogger.error(
                  'Failed to record location history',
                  error: error,
                  stackTrace: stackTrace,
                );
              }),
        );
      }
    });
  }

  @override
  Future<void> stopSharing() async {
    await _subscription?.cancel();
    _subscription = null;
    _activeSessionId = null;
    _lastRecordedHistoryFix = null;
  }
}
