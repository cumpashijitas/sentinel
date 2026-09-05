import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/maps/domain/entities/map_marker.dart';
import 'package:sentinel_v2/features/rides/domain/entities/location_fix.dart';
import 'package:sentinel_v2/features/rides/domain/entities/member_location.dart';
import 'package:sentinel_v2/features/rides/presentation/utils/member_map_markers.dart';

MemberLocation _member(
  String userId, {
  LocationFix? fix,
  MemberTrackingStatus status = MemberTrackingStatus.active,
}) => MemberLocation(
  userId: userId,
  displayName: userId,
  fix: fix,
  status: status,
);

LocationFix _fix({double? speed, double? heading}) => LocationFix(
  latitude: -17.3935,
  longitude: -66.1570,
  speed: speed,
  heading: heading,
  recordedAt: DateTime.utc(2026, 8, 27),
);

void main() {
  group('buildMemberMapMarkers', () {
    test('creates one marker per member with a fix', () {
      final markers = buildMemberMapMarkers([
        _member('u1', fix: _fix()),
        _member('u2', fix: _fix()),
      ], currentUserId: null);

      expect(markers, hasLength(2));
      expect(markers.map((m) => m.id), containsAll(['u1', 'u2']));
    });

    test('skips members without a fix — nothing to place on the map', () {
      final markers = buildMemberMapMarkers([
        _member('u1'),
      ], currentUserId: null);

      expect(markers, isEmpty);
    });

    test('places the marker at the fix coordinates', () {
      final markers = buildMemberMapMarkers([
        _member('u1', fix: _fix()),
      ], currentUserId: null);

      final marker = markers.single;
      expect(marker.coordinate.latitude, -17.3935);
      expect(marker.coordinate.longitude, -66.1570);
    });

    test('categorizes the current user distinctly from other members', () {
      final markers = buildMemberMapMarkers([
        _member('u1', fix: _fix()),
        _member('u2', fix: _fix()),
      ], currentUserId: 'u1');

      final byId = {for (final m in markers) m.id: m};
      expect(byId['u1']!.category, MapMarkerCategory.currentUser);
      expect(byId['u2']!.category, MapMarkerCategory.member);
    });

    test('maps each MemberTrackingStatus to a MapMarkerStatus', () {
      for (final status in MemberTrackingStatus.values) {
        final markers = buildMemberMapMarkers([
          _member('u1', fix: _fix(), status: status),
        ], currentUserId: null);

        expect(markers.single.status, isNotNull);
      }
    });

    test('converts GPS speed (m/s) to km/h', () {
      final markers = buildMemberMapMarkers([
        _member('u1', fix: _fix(speed: 10)),
      ], currentUserId: null);

      expect(markers.single.speedKmh, closeTo(36, 0.001));
    });

    test('carries the heading through unchanged', () {
      final markers = buildMemberMapMarkers([
        _member('u1', fix: _fix(heading: 120)),
      ], currentUserId: null);

      expect(markers.single.headingDegrees, 120);
    });
  });

  group('memberStatusLabel', () {
    test('has a distinct, non-empty label for every status', () {
      final labels = MemberTrackingStatus.values.map(memberStatusLabel).toSet();

      expect(labels, hasLength(MemberTrackingStatus.values.length));
      expect(labels, everyElement(isNotEmpty));
    });
  });
}
