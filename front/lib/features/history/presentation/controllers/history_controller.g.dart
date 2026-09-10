// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every `finished` ride the signed-in user participated in, newest first.

@ProviderFor(rideHistory)
final rideHistoryProvider = RideHistoryProvider._();

/// Every `finished` ride the signed-in user participated in, newest first.

final class RideHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideHistoryEntry>>,
          List<RideHistoryEntry>,
          FutureOr<List<RideHistoryEntry>>
        >
    with
        $FutureModifier<List<RideHistoryEntry>>,
        $FutureProvider<List<RideHistoryEntry>> {
  /// Every `finished` ride the signed-in user participated in, newest first.
  RideHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<RideHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RideHistoryEntry>> create(Ref ref) {
    return rideHistory(ref);
  }
}

String _$rideHistoryHash() => r'4035d9fe7d5535b81da2e0f62bc83a8a6ac9a215';

/// Every share ("viaje individual") the signed-in user has ended, newest
/// first — pedido explícito en vivo, junto a [rideHistoryProvider] para
/// las de grupo.

@ProviderFor(shareHistory)
final shareHistoryProvider = ShareHistoryProvider._();

/// Every share ("viaje individual") the signed-in user has ended, newest
/// first — pedido explícito en vivo, junto a [rideHistoryProvider] para
/// las de grupo.

final class ShareHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmergencyShare>>,
          List<EmergencyShare>,
          FutureOr<List<EmergencyShare>>
        >
    with
        $FutureModifier<List<EmergencyShare>>,
        $FutureProvider<List<EmergencyShare>> {
  /// Every share ("viaje individual") the signed-in user has ended, newest
  /// first — pedido explícito en vivo, junto a [rideHistoryProvider] para
  /// las de grupo.
  ShareHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<EmergencyShare>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EmergencyShare>> create(Ref ref) {
    return shareHistory(ref);
  }
}

String _$shareHistoryHash() => r'b82b0323c217ee45adcfb9c023fb77a4528dacb7';

/// [rideHistoryProvider] and [shareHistoryProvider] merged into a single
/// chronological feed — what the "Viajes" tab actually renders. See
/// [RouteHistoryMerger].

@ProviderFor(routeHistory)
final routeHistoryProvider = RouteHistoryProvider._();

/// [rideHistoryProvider] and [shareHistoryProvider] merged into a single
/// chronological feed — what the "Viajes" tab actually renders. See
/// [RouteHistoryMerger].

final class RouteHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RouteHistoryEntry>>,
          List<RouteHistoryEntry>,
          FutureOr<List<RouteHistoryEntry>>
        >
    with
        $FutureModifier<List<RouteHistoryEntry>>,
        $FutureProvider<List<RouteHistoryEntry>> {
  /// [rideHistoryProvider] and [shareHistoryProvider] merged into a single
  /// chronological feed — what the "Viajes" tab actually renders. See
  /// [RouteHistoryMerger].
  RouteHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<RouteHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RouteHistoryEntry>> create(Ref ref) {
    return routeHistory(ref);
  }
}

String _$routeHistoryHash() => r'e7bd3321cf6a1454e044418eeea2e3aa2b6259c2';

/// Every accident event the signed-in user has ever reported, any status,
/// newest first.

@ProviderFor(accidentHistory)
final accidentHistoryProvider = AccidentHistoryProvider._();

/// Every accident event the signed-in user has ever reported, any status,
/// newest first.

final class AccidentHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccidentEvent>>,
          List<AccidentEvent>,
          FutureOr<List<AccidentEvent>>
        >
    with
        $FutureModifier<List<AccidentEvent>>,
        $FutureProvider<List<AccidentEvent>> {
  /// Every accident event the signed-in user has ever reported, any status,
  /// newest first.
  AccidentHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accidentHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accidentHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<AccidentEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AccidentEvent>> create(Ref ref) {
    return accidentHistory(ref);
  }
}

String _$accidentHistoryHash() => r'5666508c5051e745e1c10b9752002ff151e42724';

/// A single accident event by id — used by the history list's detail page,
/// reached either from [accidentHistoryProvider] or a direct
/// `/accidents/:id` link.

@ProviderFor(accidentDetail)
final accidentDetailProvider = AccidentDetailFamily._();

/// A single accident event by id — used by the history list's detail page,
/// reached either from [accidentHistoryProvider] or a direct
/// `/accidents/:id` link.

final class AccidentDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccidentEvent>,
          AccidentEvent,
          FutureOr<AccidentEvent>
        >
    with $FutureModifier<AccidentEvent>, $FutureProvider<AccidentEvent> {
  /// A single accident event by id — used by the history list's detail page,
  /// reached either from [accidentHistoryProvider] or a direct
  /// `/accidents/:id` link.
  AccidentDetailProvider._({
    required AccidentDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accidentDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accidentDetailHash();

  @override
  String toString() {
    return r'accidentDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AccidentEvent> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccidentEvent> create(Ref ref) {
    final argument = this.argument as String;
    return accidentDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccidentDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accidentDetailHash() => r'1deabcfaec8d20b1c17e3549283057691af9edd3';

/// A single accident event by id — used by the history list's detail page,
/// reached either from [accidentHistoryProvider] or a direct
/// `/accidents/:id` link.

final class AccidentDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AccidentEvent>, String> {
  AccidentDetailFamily._()
    : super(
        retry: null,
        name: r'accidentDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single accident event by id — used by the history list's detail page,
  /// reached either from [accidentHistoryProvider] or a direct
  /// `/accidents/:id` link.

  AccidentDetailProvider call(String accidentId) =>
      AccidentDetailProvider._(argument: accidentId, from: this);

  @override
  String toString() => r'accidentDetailProvider';
}

/// Derived from [rideHistoryProvider]/[shareHistoryProvider]/
/// [accidentHistoryProvider] — see [RideStatisticsCalculator] for why this
/// isn't its own datasource call.

@ProviderFor(rideStatistics)
final rideStatisticsProvider = RideStatisticsProvider._();

/// Derived from [rideHistoryProvider]/[shareHistoryProvider]/
/// [accidentHistoryProvider] — see [RideStatisticsCalculator] for why this
/// isn't its own datasource call.

final class RideStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideStatistics>,
          RideStatistics,
          FutureOr<RideStatistics>
        >
    with $FutureModifier<RideStatistics>, $FutureProvider<RideStatistics> {
  /// Derived from [rideHistoryProvider]/[shareHistoryProvider]/
  /// [accidentHistoryProvider] — see [RideStatisticsCalculator] for why this
  /// isn't its own datasource call.
  RideStatisticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideStatisticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideStatisticsHash();

  @$internal
  @override
  $FutureProviderElement<RideStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RideStatistics> create(Ref ref) {
    return rideStatistics(ref);
  }
}

String _$rideStatisticsHash() => r'5975c5f8fae11486b5e8d6f2e31be3eef767c625';
