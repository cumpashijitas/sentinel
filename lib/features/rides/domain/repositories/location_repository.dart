/// Orchestrates "share my location for this ride": watches
/// [LocationTracker] and, for every fix it emits, decides what to do with
/// it — always upsert it to `live_locations` (via [LiveLocationRepository]),
/// and additionally append a sampled row to `location_history` when
/// [LocationSamplingPolicy] says the fix is different enough from the last
/// one recorded.
///
/// This is the *only* seam the UI/controller is expected to call to start
/// or stop sharing — it owns the subscription lifecycle internally, so
/// `stopSharing()` is guaranteed to release the device-position stream
/// (important on Web, where a live GPS watch keeps the browser's location
/// indicator on) without the caller needing to manage a
/// `StreamSubscription` itself.
///
/// Deliberately a separate interface from [LiveLocationRepository]
/// (Supabase I/O) and [LocationTracker] (device I/O): this one holds no
/// I/O of its own, only the policy of *when* to call the other two. That
/// split is what keeps the sampling policy unit-testable without a device
/// or a network — see
/// `test/features/rides/domain/services/location_sampling_policy_test.dart`.
abstract interface class LocationRepository {
  /// Starts watching the device (requesting permission first if needed)
  /// and pushing fixes for [sessionId]. A no-op if already sharing for
  /// this same session; switches sessions if a different one was active.
  /// Throws [DataException]-style errors from the underlying
  /// tracker/repository if permission is denied or the initial write
  /// fails.
  Future<void> startSharing(String sessionId);

  /// Stops watching the device and releases the subscription. Safe to
  /// call even when not currently sharing.
  Future<void> stopSharing();

  /// Whether a sharing session is currently active.
  bool get isSharing;
}
