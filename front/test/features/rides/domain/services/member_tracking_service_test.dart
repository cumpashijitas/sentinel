import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/entities/member_location.dart';
import 'package:sentinel_v2/features/rides/domain/entities/ride_session_participant.dart';
import 'package:sentinel_v2/features/rides/domain/services/member_tracking_service.dart';

final _now = DateTime.utc(2026, 8, 27, 12);

RideSessionParticipant _participant(String userId, {String? name}) =>
    RideSessionParticipant(
      sessionId: 's1',
      userId: userId,
      status: RideParticipantStatus.active,
      joinedAt: _now.subtract(const Duration(minutes: 10)),
      displayName: name ?? userId,
    );

LocationFix _fixAgo(
  Duration age, {
  double lat = -17.3935,
  double lng = -66.1570,
}) =>
    LocationFix(latitude: lat, longitude: lng, recordedAt: _now.subtract(age));

void main() {
  // Exercises the config's own defaults: 500m / 45s / 180s.
  const service = MemberTrackingService();

  group('MemberTrackingService.computeStatuses', () {
    test('a participant with no fix at all is offline', () {
      final result = service.computeStatuses(
        participants: [_participant('u1')],
        fixesByUserId: const {},
        now: _now,
      );

      expect(result.single.status, MemberTrackingStatus.offline);
      expect(result.single.fix, isNull);
    });

    test('a recent fix close to the group is active', () {
      final result = service.computeStatuses(
        participants: [_participant('u1'), _participant('u2')],
        fixesByUserId: {
          'u1': _fixAgo(const Duration(seconds: 5)),
          'u2': _fixAgo(
            const Duration(seconds: 5),
            lat: -17.3936,
            lng: -66.1571,
          ),
        },
        now: _now,
      );

      expect(
        result.map((m) => m.status),
        everyElement(MemberTrackingStatus.active),
      );
    });

    test(
      'a fix older than staleLocationSeconds but younger than offline is stale',
      () {
        final result = service.computeStatuses(
          participants: [_participant('u1')],
          fixesByUserId: {'u1': _fixAgo(const Duration(seconds: 90))},
          now: _now,
        );

        expect(result.single.status, MemberTrackingStatus.stale);
      },
    );

    test('a fix older than offlineLocationSeconds is offline, not stale', () {
      final result = service.computeStatuses(
        participants: [_participant('u1')],
        fixesByUserId: {'u1': _fixAgo(const Duration(seconds: 200))},
        now: _now,
      );

      expect(result.single.status, MemberTrackingStatus.offline);
    });

    test('a recent fix far from the group is lagging', () {
      // 3 riders clustered together + 1 ~900m away. The straggler
      // strategy compares each rider against *everyone else*, so with a
      // small group an outlier pulls the "other members'" centroid toward
      // itself too — using 3-close-vs-1-far (rather than 2-vs-1) keeps
      // that pull under the threshold for the close riders while the
      // outlier itself is still clearly over it. See
      // `CentroidStragglerDetectionStrategy`'s doc comment.
      final result = service.computeStatuses(
        participants: [
          _participant('u1'),
          _participant('u2'),
          _participant('u3'),
          _participant('u4'),
        ],
        fixesByUserId: {
          'u1': _fixAgo(const Duration(seconds: 5)),
          'u2': _fixAgo(
            const Duration(seconds: 5),
            lat: -17.3936,
            lng: -66.1571,
          ),
          'u3': _fixAgo(
            const Duration(seconds: 5),
            lat: -17.3934,
            lng: -66.1569,
          ),
          // ~900m south of the cluster above — well beyond the 500m
          // threshold, even diluted across 3 "other" close members.
          'u4': _fixAgo(const Duration(seconds: 5), lat: -17.4016),
        },
        now: _now,
      );

      final u4 = result.firstWhere((m) => m.userId == 'u4');
      expect(u4.status, MemberTrackingStatus.lagging);
      // u1/u2/u3 stay active — they're close to each other, and u4's pull
      // on their "others" centroid is diluted by being outnumbered 3-to-1.
      expect(
        result.where((m) => m.userId != 'u4').map((m) => m.status),
        everyElement(MemberTrackingStatus.active),
      );
    });

    test(
      'a single participant with nobody else in the session is never lagging',
      () {
        final result = service.computeStatuses(
          participants: [_participant('u1')],
          fixesByUserId: {'u1': _fixAgo(const Duration(seconds: 5))},
          now: _now,
        );

        expect(result.single.status, MemberTrackingStatus.active);
      },
    );

    test(
      "a stale/offline member's old fix does not distort the group centroid",
      () {
        final result = service.computeStatuses(
          participants: [
            _participant('u1'),
            _participant('u2'),
            _participant('u3'),
          ],
          fixesByUserId: {
            'u1': _fixAgo(const Duration(seconds: 5)),
            'u2': _fixAgo(
              const Duration(seconds: 5),
              lat: -17.3936,
              lng: -66.1571,
            ),
            // u3 is offline (fix far too old) AND geographically far away —
            // it must not pull the centroid toward it.
            'u3': _fixAgo(const Duration(seconds: 300), lat: -17.4135),
          },
          now: _now,
        );

        final u3 = result.firstWhere((m) => m.userId == 'u3');
        expect(u3.status, MemberTrackingStatus.offline);
        expect(
          result.where((m) => m.userId != 'u3').map((m) => m.status),
          everyElement(MemberTrackingStatus.active),
        );
      },
    );

    test(
      'preserves participant display info on the resulting MemberLocation',
      () {
        final result = service.computeStatuses(
          participants: [_participant('u1', name: 'Ana Rider')],
          fixesByUserId: {'u1': _fixAgo(const Duration(seconds: 5))},
          now: _now,
        );

        expect(result.single.displayName, 'Ana Rider');
        expect(result.single.userId, 'u1');
      },
    );
  });
}
