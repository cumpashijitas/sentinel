// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_sessions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rideSessionRemoteDataSource)
final rideSessionRemoteDataSourceProvider =
    RideSessionRemoteDataSourceProvider._();

final class RideSessionRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          RideSessionRemoteDataSource,
          RideSessionRemoteDataSource,
          RideSessionRemoteDataSource
        >
    with $Provider<RideSessionRemoteDataSource> {
  RideSessionRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideSessionRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideSessionRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<RideSessionRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RideSessionRemoteDataSource create(Ref ref) {
    return rideSessionRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideSessionRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideSessionRemoteDataSource>(value),
    );
  }
}

String _$rideSessionRemoteDataSourceHash() =>
    r'c4f74cdb9cf3ff12a532613f08395cf43461b1c1';

@ProviderFor(rideSessionRepository)
final rideSessionRepositoryProvider = RideSessionRepositoryProvider._();

final class RideSessionRepositoryProvider
    extends
        $FunctionalProvider<
          RideSessionRepository,
          RideSessionRepository,
          RideSessionRepository
        >
    with $Provider<RideSessionRepository> {
  RideSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<RideSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RideSessionRepository create(Ref ref) {
    return rideSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideSessionRepository>(value),
    );
  }
}

String _$rideSessionRepositoryHash() =>
    r'8dda70de55bf602d7612b76315a54de3f054cc72';

/// The group's current `waiting`/`active` session, or `null`. Drives
/// whether `GroupDetailPage` shows "start a ride" or "open the active
/// ride". Invalidated by [RideSessionActionsController] after starting or
/// finishing a session.

@ProviderFor(activeSession)
final activeSessionProvider = ActiveSessionFamily._();

/// The group's current `waiting`/`active` session, or `null`. Drives
/// whether `GroupDetailPage` shows "start a ride" or "open the active
/// ride". Invalidated by [RideSessionActionsController] after starting or
/// finishing a session.

final class ActiveSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideSession?>,
          RideSession?,
          FutureOr<RideSession?>
        >
    with $FutureModifier<RideSession?>, $FutureProvider<RideSession?> {
  /// The group's current `waiting`/`active` session, or `null`. Drives
  /// whether `GroupDetailPage` shows "start a ride" or "open the active
  /// ride". Invalidated by [RideSessionActionsController] after starting or
  /// finishing a session.
  ActiveSessionProvider._({
    required ActiveSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeSessionHash();

  @override
  String toString() {
    return r'activeSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RideSession?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RideSession?> create(Ref ref) {
    final argument = this.argument as String;
    return activeSession(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeSessionHash() => r'a740ac92c5da69676f05b2844e53a21d57462bb3';

/// The group's current `waiting`/`active` session, or `null`. Drives
/// whether `GroupDetailPage` shows "start a ride" or "open the active
/// ride". Invalidated by [RideSessionActionsController] after starting or
/// finishing a session.

final class ActiveSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RideSession?>, String> {
  ActiveSessionFamily._()
    : super(
        retry: null,
        name: r'activeSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The group's current `waiting`/`active` session, or `null`. Drives
  /// whether `GroupDetailPage` shows "start a ride" or "open the active
  /// ride". Invalidated by [RideSessionActionsController] after starting or
  /// finishing a session.

  ActiveSessionProvider call(String groupId) =>
      ActiveSessionProvider._(argument: groupId, from: this);

  @override
  String toString() => r'activeSessionProvider';
}

/// A single session's details, by id.

@ProviderFor(rideSession)
final rideSessionProvider = RideSessionFamily._();

/// A single session's details, by id.

final class RideSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideSession>,
          RideSession,
          FutureOr<RideSession>
        >
    with $FutureModifier<RideSession>, $FutureProvider<RideSession> {
  /// A single session's details, by id.
  RideSessionProvider._({
    required RideSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideSessionHash();

  @override
  String toString() {
    return r'rideSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RideSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RideSession> create(Ref ref) {
    final argument = this.argument as String;
    return rideSession(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RideSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideSessionHash() => r'd5c76c31f25659f3c55b43533ee5737ca314a83f';

/// A single session's details, by id.

final class RideSessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RideSession>, String> {
  RideSessionFamily._()
    : super(
        retry: null,
        name: r'rideSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single session's details, by id.

  RideSessionProvider call(String sessionId) =>
      RideSessionProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'rideSessionProvider';
}

/// The roster of a single session, by id.

@ProviderFor(rideParticipants)
final rideParticipantsProvider = RideParticipantsFamily._();

/// The roster of a single session, by id.

final class RideParticipantsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideSessionParticipant>>,
          List<RideSessionParticipant>,
          FutureOr<List<RideSessionParticipant>>
        >
    with
        $FutureModifier<List<RideSessionParticipant>>,
        $FutureProvider<List<RideSessionParticipant>> {
  /// The roster of a single session, by id.
  RideParticipantsProvider._({
    required RideParticipantsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideParticipantsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideParticipantsHash();

  @override
  String toString() {
    return r'rideParticipantsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RideSessionParticipant>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RideSessionParticipant>> create(Ref ref) {
    final argument = this.argument as String;
    return rideParticipants(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RideParticipantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideParticipantsHash() => r'1f3e21964a15f3a730c559173ffe96efcab174fb';

/// The roster of a single session, by id.

final class RideParticipantsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<RideSessionParticipant>>,
          String
        > {
  RideParticipantsFamily._()
    : super(
        retry: null,
        name: r'rideParticipantsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The roster of a single session, by id.

  RideParticipantsProvider call(String sessionId) =>
      RideParticipantsProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'rideParticipantsProvider';
}

/// Drives start/finish. Same shape as [GroupActionsController]: the state
/// is only the action's own loading/error/success, but each method also
/// *returns* the resulting session so the page can navigate/refresh
/// without a second round trip through a provider.

@ProviderFor(RideSessionActionsController)
final rideSessionActionsControllerProvider =
    RideSessionActionsControllerProvider._();

/// Drives start/finish. Same shape as [GroupActionsController]: the state
/// is only the action's own loading/error/success, but each method also
/// *returns* the resulting session so the page can navigate/refresh
/// without a second round trip through a provider.
final class RideSessionActionsControllerProvider
    extends $AsyncNotifierProvider<RideSessionActionsController, void> {
  /// Drives start/finish. Same shape as [GroupActionsController]: the state
  /// is only the action's own loading/error/success, but each method also
  /// *returns* the resulting session so the page can navigate/refresh
  /// without a second round trip through a provider.
  RideSessionActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideSessionActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideSessionActionsControllerHash();

  @$internal
  @override
  RideSessionActionsController create() => RideSessionActionsController();
}

String _$rideSessionActionsControllerHash() =>
    r'd6c27cfcfddaaf677ef9350825c2b2e71dcea1f7';

/// Drives start/finish. Same shape as [GroupActionsController]: the state
/// is only the action's own loading/error/success, but each method also
/// *returns* the resulting session so the page can navigate/refresh
/// without a second round trip through a provider.

abstract class _$RideSessionActionsController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
