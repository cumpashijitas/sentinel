import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/features/emergency_shares/data/datasources/public_share_remote_datasource.dart';
import 'package:sentinel_v2/features/emergency_shares/data/repositories/public_share_repository_impl.dart';

Map<String, dynamic> _historyRow({double lat = -17.3935}) => {
  'latitude': lat,
  'longitude': -66.1570,
  'recorded_at': '2026-08-27T12:00:00.000Z',
};

class _FakePublicShareRemoteDataSource implements PublicShareRemoteDataSource {
  List<Map<String, dynamic>> historyRowsToReturn = [];

  @override
  Future<Map<String, dynamic>> fetchByToken(String token) =>
      throw UnimplementedError();

  @override
  Stream<Map<String, dynamic>> watchByToken(String token) =>
      throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> fetchHistory(String token) async =>
      historyRowsToReturn;
}

void main() {
  group('PublicShareRepositoryImpl.fetchRoute', () {
    test('maps every row into a LocationFix, in order', () async {
      final dataSource = _FakePublicShareRemoteDataSource()
        ..historyRowsToReturn = [_historyRow(), _historyRow(lat: -17.4)];
      final repository = PublicShareRepositoryImpl(dataSource);

      final route = await repository.fetchRoute('tok123');

      expect(route, hasLength(2));
      expect(route.first.latitude, -17.3935);
      expect(route.last.latitude, -17.4);
    });

    test(
      // La ruta debe seguir siendo visible aunque el share ya haya
      // terminado — ver `fetchHistoryByToken` en el backend, que no filtra
      // por `status`. Acá solo se confirma que una respuesta vacía no
      // revienta al mapear.
      'returns an empty route when there is no history yet',
      () async {
        final dataSource = _FakePublicShareRemoteDataSource();
        final repository = PublicShareRepositoryImpl(dataSource);

        final route = await repository.fetchRoute('tok123');

        expect(route, isEmpty);
      },
    );
  });
}
