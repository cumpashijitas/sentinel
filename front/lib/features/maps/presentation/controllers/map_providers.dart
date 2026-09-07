import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../data/datasources/maplibre_map_service.dart';
import '../../domain/entities/map_tile_config.dart';
import '../../domain/repositories/map_service.dart';

part 'map_providers.g.dart';

/// Built once from [AppConfig] (`front/.env`, via `flutter_dotenv`) — see
/// `MapTileConfig`'s own doc comment for why every field here matters,
/// especially `offlineAllowed`.
@riverpod
MapTileConfig mapTileConfig(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return MapTileConfig(
    styleUrl: config.mapStyleUrl,
    attribution: config.mapAttribution,
    offlineAllowed: config.mapOfflineEnabled,
    providerName: config.mapTileProvider,
  );
}

/// `keepAlive`: cheap to construct (no I/O, no native handles of its own —
/// those live in the `Widget`/`MapController` it hands out per screen),
/// but there's no reason to let it churn either.
@Riverpod(keepAlive: true)
MapService mapService(Ref ref) => MapLibreMapService();
