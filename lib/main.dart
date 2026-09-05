import 'app/bootstrap.dart';
// The native side (RideBackgroundService.kt) looks this entrypoint up by
// library URI + function name to boot a second, headless FlutterEngine —
// it is never called from here. Without this import, though, nothing in
// `main.dart`'s reachable import graph references
// `background/ride_background_main.dart`, and the compiler simply never
// includes it in the app's compiled kernel: the native lookup then fails
// at runtime with "Dart_LookupLibrary: library ... not found" (confirmed
// live on-device during Fase 6 verification, not a theoretical concern).
// ignore: unused_import
import 'background/ride_background_main.dart';

Future<void> main() => bootstrap();
