import '../../../rides/domain/entities/location_fix.dart';
import '../../domain/repositories/public_share_repository.dart';
import '../datasources/public_share_remote_datasource.dart';

class PublicShareRepositoryImpl implements PublicShareRepository {
  PublicShareRepositoryImpl(this._remoteDataSource);

  final PublicShareRemoteDataSource _remoteDataSource;

  @override
  Future<PublicShareView> fetchByToken(String token) async {
    final row = await _remoteDataSource.fetchByToken(token);
    return _toView(row);
  }

  @override
  Stream<PublicShareView> watch(String token) {
    return _remoteDataSource.watchByToken(token).map(_toView);
  }

  @override
  Future<List<LocationFix>> fetchRoute(String token) async {
    final rows = await _remoteDataSource.fetchHistory(token);
    return rows.map(LocationFix.fromJson).toList(growable: false);
  }

  PublicShareView _toView(Map<String, dynamic> row) {
    final hasFix = row['latitude'] != null && row['longitude'] != null;
    return PublicShareView(
      riderDisplayName: row['rider_display_name'] as String? ?? 'Motociclista',
      isActive: row['status'] == 'active',
      fix: hasFix
          ? LocationFix(
              latitude: (row['latitude'] as num).toDouble(),
              longitude: (row['longitude'] as num).toDouble(),
              accuracy: (row['accuracy'] as num?)?.toDouble(),
              speed: (row['speed'] as num?)?.toDouble(),
              heading: (row['heading'] as num?)?.toDouble(),
              recordedAt: DateTime.parse(row['recorded_at'] as String),
            )
          : null,
    );
  }
}
