// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupRemoteDataSource)
final groupRemoteDataSourceProvider = GroupRemoteDataSourceProvider._();

final class GroupRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          GroupRemoteDataSource,
          GroupRemoteDataSource,
          GroupRemoteDataSource
        >
    with $Provider<GroupRemoteDataSource> {
  GroupRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<GroupRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupRemoteDataSource create(Ref ref) {
    return groupRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupRemoteDataSource>(value),
    );
  }
}

String _$groupRemoteDataSourceHash() =>
    r'7a222e8e15021fc156bece79fe9e8fe254894bc5';

@ProviderFor(groupRepository)
final groupRepositoryProvider = GroupRepositoryProvider._();

final class GroupRepositoryProvider
    extends
        $FunctionalProvider<GroupRepository, GroupRepository, GroupRepository>
    with $Provider<GroupRepository> {
  GroupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupRepository create(Ref ref) {
    return groupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupRepository>(value),
    );
  }
}

String _$groupRepositoryHash() => r'0365fcdb2ce4f5e02b618f807086edee3ce08712';

/// Groups the signed-in user belongs to. Invalidated by
/// [GroupActionsController] after creating, joining, or leaving a group.

@ProviderFor(myGroups)
final myGroupsProvider = MyGroupsProvider._();

/// Groups the signed-in user belongs to. Invalidated by
/// [GroupActionsController] after creating, joining, or leaving a group.

final class MyGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideGroup>>,
          List<RideGroup>,
          FutureOr<List<RideGroup>>
        >
    with $FutureModifier<List<RideGroup>>, $FutureProvider<List<RideGroup>> {
  /// Groups the signed-in user belongs to. Invalidated by
  /// [GroupActionsController] after creating, joining, or leaving a group.
  MyGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGroupsHash();

  @$internal
  @override
  $FutureProviderElement<List<RideGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RideGroup>> create(Ref ref) {
    return myGroups(ref);
  }
}

String _$myGroupsHash() => r'556dfdf159a2e684a785d67fe04c29ee2e787842';

/// A single group's details, by id.
///
/// Named `groupDetail` rather than `group` — `group` collides with
/// `package:flutter_test`'s top-level test-grouping function in any test
/// file that imports both this provider and `flutter_test`.

@ProviderFor(groupDetail)
final groupDetailProvider = GroupDetailFamily._();

/// A single group's details, by id.
///
/// Named `groupDetail` rather than `group` — `group` collides with
/// `package:flutter_test`'s top-level test-grouping function in any test
/// file that imports both this provider and `flutter_test`.

final class GroupDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideGroup>,
          RideGroup,
          FutureOr<RideGroup>
        >
    with $FutureModifier<RideGroup>, $FutureProvider<RideGroup> {
  /// A single group's details, by id.
  ///
  /// Named `groupDetail` rather than `group` — `group` collides with
  /// `package:flutter_test`'s top-level test-grouping function in any test
  /// file that imports both this provider and `flutter_test`.
  GroupDetailProvider._({
    required GroupDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDetailHash();

  @override
  String toString() {
    return r'groupDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RideGroup> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RideGroup> create(Ref ref) {
    final argument = this.argument as String;
    return groupDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDetailHash() => r'6027e924eca69bdb263740fad4fa32263094c09f';

/// A single group's details, by id.
///
/// Named `groupDetail` rather than `group` — `group` collides with
/// `package:flutter_test`'s top-level test-grouping function in any test
/// file that imports both this provider and `flutter_test`.

final class GroupDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RideGroup>, String> {
  GroupDetailFamily._()
    : super(
        retry: null,
        name: r'groupDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single group's details, by id.
  ///
  /// Named `groupDetail` rather than `group` — `group` collides with
  /// `package:flutter_test`'s top-level test-grouping function in any test
  /// file that imports both this provider and `flutter_test`.

  GroupDetailProvider call(String groupId) =>
      GroupDetailProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupDetailProvider';
}

/// The roster of a single group, by id.

@ProviderFor(groupMembers)
final groupMembersProvider = GroupMembersFamily._();

/// The roster of a single group, by id.

final class GroupMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupMember>>,
          List<GroupMember>,
          FutureOr<List<GroupMember>>
        >
    with
        $FutureModifier<List<GroupMember>>,
        $FutureProvider<List<GroupMember>> {
  /// The roster of a single group, by id.
  GroupMembersProvider._({
    required GroupMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMembersHash();

  @override
  String toString() {
    return r'groupMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GroupMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GroupMember>> create(Ref ref) {
    final argument = this.argument as String;
    return groupMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMembersHash() => r'003e4b8f4feabb7a8942977623d2c4c6b3b63eaf';

/// The roster of a single group, by id.

final class GroupMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GroupMember>>, String> {
  GroupMembersFamily._()
    : super(
        retry: null,
        name: r'groupMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The roster of a single group, by id.

  GroupMembersProvider call(String groupId) =>
      GroupMembersProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMembersProvider';
}

/// Drives create/join/leave. Same shape as [ProfileController] (state is
/// only the action's own loading/error/success), but each method also
/// *returns* the value the UI needs right away — the created group, or the
/// joined group's id — so the page can navigate to it without a second
/// round trip through a provider.

@ProviderFor(GroupActionsController)
final groupActionsControllerProvider = GroupActionsControllerProvider._();

/// Drives create/join/leave. Same shape as [ProfileController] (state is
/// only the action's own loading/error/success), but each method also
/// *returns* the value the UI needs right away — the created group, or the
/// joined group's id — so the page can navigate to it without a second
/// round trip through a provider.
final class GroupActionsControllerProvider
    extends $AsyncNotifierProvider<GroupActionsController, void> {
  /// Drives create/join/leave. Same shape as [ProfileController] (state is
  /// only the action's own loading/error/success), but each method also
  /// *returns* the value the UI needs right away — the created group, or the
  /// joined group's id — so the page can navigate to it without a second
  /// round trip through a provider.
  GroupActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupActionsControllerHash();

  @$internal
  @override
  GroupActionsController create() => GroupActionsController();
}

String _$groupActionsControllerHash() =>
    r'c8dc0c3f2fbe99dda02ee75a8fca7a5866bff9e2';

/// Drives create/join/leave. Same shape as [ProfileController] (state is
/// only the action's own loading/error/success), but each method also
/// *returns* the value the UI needs right away — the created group, or the
/// joined group's id — so the page can navigate to it without a second
/// round trip through a provider.

abstract class _$GroupActionsController extends $AsyncNotifier<void> {
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

/// Bug real encontrado en vivo: `edit` vivía antes en
/// [GroupActionsController], compartiendo `state` con `leave` — y
/// `GroupDetailPage` tiene un `ref.listen(groupActionsControllerProvider,
/// ...)` que hace `context.pop()` en cuanto ve loading→data, escrito
/// pensando solo en "salir del grupo terminó, volvé a la lista". Guardar
/// una edición también dispara loading→data en ese mismo provider, así que
/// ese listener se activaba igual y sacaba a la persona de la pantalla
/// (o competía con el propio `Navigator.pop()` del sheet de edición) justo
/// al guardar — el "se traba y no hace nada" reportado en vivo. Un
/// controlador separado, que nadie más escucha, corta esa interferencia.

@ProviderFor(GroupEditController)
final groupEditControllerProvider = GroupEditControllerProvider._();

/// Bug real encontrado en vivo: `edit` vivía antes en
/// [GroupActionsController], compartiendo `state` con `leave` — y
/// `GroupDetailPage` tiene un `ref.listen(groupActionsControllerProvider,
/// ...)` que hace `context.pop()` en cuanto ve loading→data, escrito
/// pensando solo en "salir del grupo terminó, volvé a la lista". Guardar
/// una edición también dispara loading→data en ese mismo provider, así que
/// ese listener se activaba igual y sacaba a la persona de la pantalla
/// (o competía con el propio `Navigator.pop()` del sheet de edición) justo
/// al guardar — el "se traba y no hace nada" reportado en vivo. Un
/// controlador separado, que nadie más escucha, corta esa interferencia.
final class GroupEditControllerProvider
    extends $AsyncNotifierProvider<GroupEditController, void> {
  /// Bug real encontrado en vivo: `edit` vivía antes en
  /// [GroupActionsController], compartiendo `state` con `leave` — y
  /// `GroupDetailPage` tiene un `ref.listen(groupActionsControllerProvider,
  /// ...)` que hace `context.pop()` en cuanto ve loading→data, escrito
  /// pensando solo en "salir del grupo terminó, volvé a la lista". Guardar
  /// una edición también dispara loading→data en ese mismo provider, así que
  /// ese listener se activaba igual y sacaba a la persona de la pantalla
  /// (o competía con el propio `Navigator.pop()` del sheet de edición) justo
  /// al guardar — el "se traba y no hace nada" reportado en vivo. Un
  /// controlador separado, que nadie más escucha, corta esa interferencia.
  GroupEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupEditControllerHash();

  @$internal
  @override
  GroupEditController create() => GroupEditController();
}

String _$groupEditControllerHash() =>
    r'6d48912a78d5508829b8621d960e1dc809498f83';

/// Bug real encontrado en vivo: `edit` vivía antes en
/// [GroupActionsController], compartiendo `state` con `leave` — y
/// `GroupDetailPage` tiene un `ref.listen(groupActionsControllerProvider,
/// ...)` que hace `context.pop()` en cuanto ve loading→data, escrito
/// pensando solo en "salir del grupo terminó, volvé a la lista". Guardar
/// una edición también dispara loading→data en ese mismo provider, así que
/// ese listener se activaba igual y sacaba a la persona de la pantalla
/// (o competía con el propio `Navigator.pop()` del sheet de edición) justo
/// al guardar — el "se traba y no hace nada" reportado en vivo. Un
/// controlador separado, que nadie más escucha, corta esa interferencia.

abstract class _$GroupEditController extends $AsyncNotifier<void> {
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

/// Asignar/quitar admin y expulsar integrantes — controlador propio, no
/// compartido con [GroupActionsController]/[GroupEditController], mismo
/// motivo que [GroupEditController]: `GroupDetailPage` escucha el `state`
/// de `GroupActionsController` para saber cuándo "salir del grupo"
/// terminó y sacar al usuario de la pantalla — una acción de member
/// management disparando ese mismo listener por accidente sería
/// exactamente el bug ya encontrado una vez.

@ProviderFor(GroupMemberActionsController)
final groupMemberActionsControllerProvider =
    GroupMemberActionsControllerProvider._();

/// Asignar/quitar admin y expulsar integrantes — controlador propio, no
/// compartido con [GroupActionsController]/[GroupEditController], mismo
/// motivo que [GroupEditController]: `GroupDetailPage` escucha el `state`
/// de `GroupActionsController` para saber cuándo "salir del grupo"
/// terminó y sacar al usuario de la pantalla — una acción de member
/// management disparando ese mismo listener por accidente sería
/// exactamente el bug ya encontrado una vez.
final class GroupMemberActionsControllerProvider
    extends $AsyncNotifierProvider<GroupMemberActionsController, void> {
  /// Asignar/quitar admin y expulsar integrantes — controlador propio, no
  /// compartido con [GroupActionsController]/[GroupEditController], mismo
  /// motivo que [GroupEditController]: `GroupDetailPage` escucha el `state`
  /// de `GroupActionsController` para saber cuándo "salir del grupo"
  /// terminó y sacar al usuario de la pantalla — una acción de member
  /// management disparando ese mismo listener por accidente sería
  /// exactamente el bug ya encontrado una vez.
  GroupMemberActionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupMemberActionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupMemberActionsControllerHash();

  @$internal
  @override
  GroupMemberActionsController create() => GroupMemberActionsController();
}

String _$groupMemberActionsControllerHash() =>
    r'1d3f0e826e78807ac9f972dff5c5aef0f72ed693';

/// Asignar/quitar admin y expulsar integrantes — controlador propio, no
/// compartido con [GroupActionsController]/[GroupEditController], mismo
/// motivo que [GroupEditController]: `GroupDetailPage` escucha el `state`
/// de `GroupActionsController` para saber cuándo "salir del grupo"
/// terminó y sacar al usuario de la pantalla — una acción de member
/// management disparando ese mismo listener por accidente sería
/// exactamente el bug ya encontrado una vez.

abstract class _$GroupMemberActionsController extends $AsyncNotifier<void> {
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

/// El aviso fijado del grupo — controlador propio por la misma razón que
/// [GroupEditController].

@ProviderFor(GroupNoteController)
final groupNoteControllerProvider = GroupNoteControllerProvider._();

/// El aviso fijado del grupo — controlador propio por la misma razón que
/// [GroupEditController].
final class GroupNoteControllerProvider
    extends $AsyncNotifierProvider<GroupNoteController, void> {
  /// El aviso fijado del grupo — controlador propio por la misma razón que
  /// [GroupEditController].
  GroupNoteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupNoteControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupNoteControllerHash();

  @$internal
  @override
  GroupNoteController create() => GroupNoteController();
}

String _$groupNoteControllerHash() =>
    r'4cd9808a52947c6df76b56f12a73d8d4d3d4fb72';

/// El aviso fijado del grupo — controlador propio por la misma razón que
/// [GroupEditController].

abstract class _$GroupNoteController extends $AsyncNotifier<void> {
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
