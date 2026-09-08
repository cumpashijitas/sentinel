import '../../../rides/domain/entities/location_fix.dart';

/// The rider's public-facing info + last known position for a share link —
/// what `PublicSharePage` renders. No `fromJson`: assembled from the
/// combined row `back/`'s public route already joins server-side.
class PublicShareView {
  const PublicShareView({
    required this.riderDisplayName,
    required this.isActive,
    required this.fix,
  });

  final String riderDisplayName;
  final bool isActive;

  /// `null` if the rider hasn't sent a fix yet.
  final LocationFix? fix;
}

/// Backend-agnostic contract for viewing someone else's share via its
/// public link (`/share/<token>`) — **no account, no JWT**. Anyone who has
/// the token can read this; see `back/src/routes/public.routes.ts`.
abstract interface class PublicShareRepository {
  /// One-shot read — used to seed the screen before [watch] starts
  /// delivering live changes. Throws if the token doesn't match an
  /// existing share.
  Future<PublicShareView> fetchByToken(String token);

  /// Emits every position update the rider sends while the share stays
  /// active. Never completes on its own — cancel the subscription when the
  /// viewing screen closes.
  Stream<PublicShareView> watch(String token);
}
