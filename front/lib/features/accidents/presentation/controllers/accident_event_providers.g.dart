// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accident_event_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `AccidentMonitorServiceImpl` (Fase 7) and `accident_alert_response.dart`
/// construct `AccidentEventRepositoryImpl` by hand instead of through this
/// provider — both run outside the main widget tree (a headless background
/// `FlutterEngine`, a notification-tap handler wired in `bootstrap()`
/// before `ProviderScope` exists), so there's no `Ref` to read from there.
/// This provider exists for the parts of the app that *do* run inside the
/// widget tree and need read access — Fase 9's history/detail screens.

@ProviderFor(accidentEventRemoteDataSource)
final accidentEventRemoteDataSourceProvider =
    AccidentEventRemoteDataSourceProvider._();

/// `AccidentMonitorServiceImpl` (Fase 7) and `accident_alert_response.dart`
/// construct `AccidentEventRepositoryImpl` by hand instead of through this
/// provider — both run outside the main widget tree (a headless background
/// `FlutterEngine`, a notification-tap handler wired in `bootstrap()`
/// before `ProviderScope` exists), so there's no `Ref` to read from there.
/// This provider exists for the parts of the app that *do* run inside the
/// widget tree and need read access — Fase 9's history/detail screens.

final class AccidentEventRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AccidentEventRemoteDataSource,
          AccidentEventRemoteDataSource,
          AccidentEventRemoteDataSource
        >
    with $Provider<AccidentEventRemoteDataSource> {
  /// `AccidentMonitorServiceImpl` (Fase 7) and `accident_alert_response.dart`
  /// construct `AccidentEventRepositoryImpl` by hand instead of through this
  /// provider — both run outside the main widget tree (a headless background
  /// `FlutterEngine`, a notification-tap handler wired in `bootstrap()`
  /// before `ProviderScope` exists), so there's no `Ref` to read from there.
  /// This provider exists for the parts of the app that *do* run inside the
  /// widget tree and need read access — Fase 9's history/detail screens.
  AccidentEventRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accidentEventRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accidentEventRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AccidentEventRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccidentEventRemoteDataSource create(Ref ref) {
    return accidentEventRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccidentEventRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccidentEventRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$accidentEventRemoteDataSourceHash() =>
    r'82b9bfa119e32643e0b644049bf42c9c1e6fc959';

@ProviderFor(accidentEventRepository)
final accidentEventRepositoryProvider = AccidentEventRepositoryProvider._();

final class AccidentEventRepositoryProvider
    extends
        $FunctionalProvider<
          AccidentEventRepository,
          AccidentEventRepository,
          AccidentEventRepository
        >
    with $Provider<AccidentEventRepository> {
  AccidentEventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accidentEventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accidentEventRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccidentEventRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccidentEventRepository create(Ref ref) {
    return accidentEventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccidentEventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccidentEventRepository>(value),
    );
  }
}

String _$accidentEventRepositoryHash() =>
    r'24493ca841e4ed711cc35b446088cf02f55d9e93';
