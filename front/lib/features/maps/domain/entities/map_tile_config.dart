/// Where the map's visual tiles/style come from — deliberately never
/// hardcoded inside a widget (see `docs/maps.md`). Built once from
/// `AppConfig` (i.e. from `--dart-define-from-file`, see
/// `core/config/app_config.dart`) and passed down to `MapLibreMapService`.
///
/// This is the single seam that keeps Sentinel from being coupled to one
/// tile provider: swapping `styleUrl` (and, later, whatever an offline
/// provider needs) in `config/*.json` is the entire migration from "online
/// demo style" to "a real, possibly offline-capable, provider" — no code
/// change.
class MapTileConfig {
  const MapTileConfig({
    required this.styleUrl,
    required this.attribution,
    required this.offlineAllowed,
    required this.providerName,
    this.tilesUrl,
  });

  /// A MapLibre style document URL (`style.json`) — what `MapLibreMap`'s
  /// `styleString` actually consumes. This is the field that matters for
  /// Fase B/C.
  final String styleUrl;

  /// A raw XYZ tile template (e.g. `https://.../{z}/{x}/{y}.png`), for a
  /// provider that hands out tiles directly instead of a full style
  /// document. Not consumed by `MapLibreMapService` yet (Fase B only wires
  /// `styleUrl`) — reserved for a provider that needs a hand-built style
  /// wrapping raw tiles.
  final String? tilesUrl;

  /// Shown on-screen at all times (see `docs/maps.md`) — required
  /// attribution text for whatever `styleUrl`/`tilesUrl` actually serves.
  /// For an OpenStreetMap-derived source this is
  /// "© OpenStreetMap contributors"; a different provider may require
  /// different (or additional) text — this field is what's actually
  /// shown, not a hardcoded OSM string.
  final String attribution;

  /// Whether [Fase D's `OfflineMapManager`] may download regions from
  /// this source at all. **Must** reflect the provider's actual terms —
  /// `tile.openstreetmap.org`'s standard tile usage policy does not permit
  /// bulk/offline download, so any config pointing there must set this to
  /// `false`. Never assume `true`; only set it once the provider's terms
  /// have actually been checked.
  final bool offlineAllowed;

  /// Human-readable identifier for logs/debugging/UI ("MapLibre demo
  /// style", "MapTiler", "self-hosted tileserver-gl", ...) — never used
  /// for branching logic (that would recouple Sentinel to specific
  /// providers, exactly what this class exists to avoid).
  final String providerName;
}
