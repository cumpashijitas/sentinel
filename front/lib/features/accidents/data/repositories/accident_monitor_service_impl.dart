import 'dart:async';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/motion_sample.dart';
import '../../domain/repositories/accident_alert_notifier.dart';
import '../../domain/repositories/accident_event_repository.dart';
import '../../domain/repositories/accident_monitor_service.dart';
import '../../domain/repositories/motion_tracker.dart';
import '../../domain/services/accident_detection_service.dart';

/// Wires [MotionTracker] → [AccidentDetectionService] →
/// [AccidentEventRepository]/[AccidentAlertNotifier] together — the actual
/// "watch sensors, report a candidate, run the countdown, resolve it"
/// state machine. See `docs/accident_detection.md` for the full flow and
/// why this deliberately does **not** attach a GPS position to the
/// candidate it reports (`latitude`/`longitude` stay `null`) — pulling in
/// `rides`' `LocationTracker` here would be a data-layer cross-feature
/// dependency this app otherwise avoids (the one accepted exception is
/// `AuthRepository`, needed everywhere for `userId` — see
/// `LocationRepositoryImpl` for the same pattern).
class AccidentMonitorServiceImpl implements AccidentMonitorService {
  // Initializing formals on private fields: still callable externally via
  // their public names (`motionTracker:`, etc.) — see the same note in
  // `LocationRepositoryImpl`'s constructor.
  AccidentMonitorServiceImpl({
    required this._motionTracker,
    required this._accidentEventRepository,
    required this._alertNotifier,
    required this._authRepository,
    this._detectionService = const AccidentDetectionService(),
    this.countdown = const Duration(seconds: 20),
  });

  final MotionTracker _motionTracker;
  final AccidentEventRepository _accidentEventRepository;
  final AccidentAlertNotifier _alertNotifier;
  final AuthRepository _authRepository;
  final AccidentDetectionService _detectionService;

  /// How long the rider has to tap "Estoy bien" before a candidate is
  /// auto-confirmed. 20s is a placeholder, not a calibrated value — see
  /// `docs/accident_detection.md`.
  final Duration countdown;

  StreamSubscription<MotionSample>? _motionSubscription;
  DateTime? _lastTriggeredAt;
  String? _activeSessionId;
  String? _pendingAccidentEventId;
  Timer? _countdownTimer;
  bool _notifierInitialized = false;

  @override
  Future<void> start(String sessionId) async {
    PlatformCapabilities.requireAndroid('AccidentMonitorService.start');

    if (_activeSessionId == sessionId && _motionSubscription != null) {
      return; // already monitoring this session
    }
    await stop();

    if (!await _motionTracker.isAvailable()) {
      // Not every Android device/emulator profile has an accelerometer —
      // degrade to "no accident detection this ride" rather than throw,
      // since location sharing (the feature this rides alongside) should
      // still work fine without it.
      AppLogger.warning(
        'AccidentMonitorService: no accelerometer available, skipping.',
      );
      return;
    }

    if (!_notifierInitialized) {
      await _alertNotifier.initialize(onConfirmedOk: _handleConfirmedOk);
      _notifierInitialized = true;
    }

    _activeSessionId = sessionId;
    _motionSubscription = _motionTracker.watchMotion().listen(_handleSample);
  }

  void _handleSample(MotionSample sample) {
    // One candidate at a time — don't evaluate new samples while a
    // countdown is already waiting on the rider's response.
    if (_pendingAccidentEventId != null) return;

    final candidate = _detectionService.evaluate(
      sample: sample,
      now: sample.recordedAt,
      lastTriggeredAt: _lastTriggeredAt,
    );
    if (candidate == null) return;

    _lastTriggeredAt = sample.recordedAt;
    unawaited(_reportAndAlert(candidate));
  }

  Future<void> _reportAndAlert(AccidentCandidate candidate) async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      AppLogger.warning(
        'AccidentMonitorService: no signed-in user, dropping candidate.',
      );
      return;
    }

    try {
      final event = await _accidentEventRepository.reportCandidate(
        userId: userId,
        sessionId: _activeSessionId,
        impactMps2: candidate.impactMps2,
        gyroRadS: candidate.gyroRadS,
        gForce: candidate.gForce,
        confidenceScore: candidate.confidenceScore,
        sample: candidate.sample,
      );
      _pendingAccidentEventId = event.id;
      await _alertNotifier.showAlert(
        accidentEventId: event.id,
        countdown: countdown,
      );
      _countdownTimer = Timer(countdown, () => unawaited(_confirmPending()));
    } catch (error, stackTrace) {
      AppLogger.error(
        'AccidentMonitorService: failed to report candidate',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _handleConfirmedOk(String accidentEventId) {
    if (_pendingAccidentEventId != accidentEventId) {
      // Stale tap (e.g. for an already-resolved event) — ignore it rather
      // than resolve whatever happens to be pending now.
      return;
    }
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _pendingAccidentEventId = null;
    unawaited(_resolve(accidentEventId, cancel: true));
  }

  Future<void> _confirmPending() async {
    final id = _pendingAccidentEventId;
    if (id == null) return;
    _pendingAccidentEventId = null;
    await _resolve(id, cancel: false);
  }

  Future<void> _resolve(String accidentEventId, {required bool cancel}) async {
    try {
      if (cancel) {
        await _accidentEventRepository.cancel(accidentEventId);
      } else {
        await _accidentEventRepository.confirm(accidentEventId);
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'AccidentMonitorService: failed to resolve candidate',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      await _alertNotifier.dismissAlert();
    }
  }

  @override
  Future<void> stop() async {
    await _motionSubscription?.cancel();
    _motionSubscription = null;
    _activeSessionId = null;

    _countdownTimer?.cancel();
    _countdownTimer = null;

    final pending = _pendingAccidentEventId;
    _pendingAccidentEventId = null;
    if (pending != null) {
      // See AccidentMonitorService.stop's doc comment: reaching stop() at
      // all is itself a "the rider is responsive" signal, so a pending
      // candidate resolves as cancelled, not left dangling.
      await _resolve(pending, cancel: true);
    }
  }
}
