/// Where the map's tiles come from — deliberately never hardcoded inside a
/// widget (see `docs/maps.md`). Built once from `AppConfig` (`front/.env`)
/// and passed down to `OsmMapService`.
///
/// This is the single seam that keeps Sentinel from being coupled to one
/// tile provider: swapping [tilesUrl] in `front/.env` is the entire
/// migration to a different XYZ tile source — no code change.
class MapTileConfig {
  const MapTileConfig({
    required this.tilesUrl,
    required this.attribution,
    required this.offlineAllowed,
    required this.providerName,
  });

  /// A raw XYZ tile template — e.g.
  /// `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. What
  /// `OsmMapService`'s `TileLayer.urlTemplate` actually consumes.
  final String tilesUrl;

  /// Shown on-screen at all times (see `docs/maps.md`) — required
  /// attribution text for whatever [tilesUrl] actually serves. For
  /// `tile.openstreetmap.org` this is "© OpenStreetMap contributors"
  /// exactly, per
  /// [OSM's tile usage policy](https://operations.osmfoundation.org/policies/tiles/);
  /// a different provider may require different (or additional) text —
  /// this field is what's actually shown, never a hardcoded OSM string.
  final String attribution;

  /// Whether the app may download/cache regions from this source for
  /// offline use. **Must** reflect the provider's actual terms —
  /// `tile.openstreetmap.org`'s usage policy explicitly forbids bulk/
  /// offline downloading ("Offline use is not permitted"), so any config
  /// pointing there must keep this `false`. Never assume `true`; only set
  /// it once a provider's terms have actually been checked to allow it.
  final bool offlineAllowed;

  /// Human-readable identifier for logs/debugging/UI ("OpenStreetMap",
  /// "MapTiler", "self-hosted tileserver-gl", ...) — never used for
  /// branching logic (that would recouple Sentinel to specific providers,
  /// exactly what this class exists to avoid).
  final String providerName;
}
