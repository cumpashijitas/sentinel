import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/accident_event_remote_datasource.dart';
import '../../data/repositories/accident_event_repository_impl.dart';
import '../../domain/repositories/accident_event_repository.dart';

part 'accident_event_providers.g.dart';

/// `AccidentMonitorServiceImpl` (Fase 7) and `accident_alert_response.dart`
/// construct `AccidentEventRepositoryImpl` by hand instead of through this
/// provider — both run outside the main widget tree (a headless background
/// `FlutterEngine`, a notification-tap handler wired in `bootstrap()`
/// before `ProviderScope` exists), so there's no `Ref` to read from there.
/// This provider exists for the parts of the app that *do* run inside the
/// widget tree and need read access — Fase 9's history/detail screens.
@riverpod
AccidentEventRemoteDataSource accidentEventRemoteDataSource(Ref ref) {
  return HttpAccidentEventRemoteDataSource(ref.watch(apiClientProvider));
}

@Riverpod(keepAlive: true)
AccidentEventRepository accidentEventRepository(Ref ref) {
  return AccidentEventRepositoryImpl(
    ref.watch(accidentEventRemoteDataSourceProvider),
  );
}
