import 'package:flutter/widgets.dart';

import '../entities/map_tile_config.dart';
import '../entities/map_viewport.dart';
import 'map_controller.dart';

/// The one seam between Sentinel's UI and whatever map engine actually
/// renders it. A page never imports `maplibre_gl` (or any other engine
/// package) directly — it calls [buildMap] and drives the result purely
/// through the [MapController] handed to [onMapReady].
///
/// Deliberately returns a [Widget] rather than fully hiding "there is a
/// widget" behind the abstraction: the map genuinely is a platform view
/// that has to live somewhere in the tree, and Flutter has no
/// widget-agnostic way around that. What *is* hidden is every engine-typed
/// parameter/callback/controller method a page would otherwise need to
/// know about.
abstract interface class MapService {
  /// Builds the map widget. [onMapReady] fires once the style has
  /// finished loading — annotations added any earlier would be silently
  /// dropped by the underlying engine, so implementations must not call
  /// it before then.
  Widget buildMap({
    required MapTileConfig tileConfig,
    required MapViewport initialViewport,
    required ValueChanged<MapController> onMapReady,
  });
}
