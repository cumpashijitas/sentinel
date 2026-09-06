import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/platform/platform_capabilities.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/emergency_contacts/presentation/pages/emergency_contacts_page.dart';
import '../features/groups/presentation/pages/group_detail_page.dart';
import '../features/groups/presentation/pages/groups_page.dart';
import '../features/history/presentation/pages/accident_detail_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/rides/presentation/pages/ride_map_page.dart';
import '../features/rides/presentation/pages/ride_session_page.dart';
import '../features/vehicles/presentation/pages/vehicles_page.dart';
import 'adaptive_shell.dart';

part 'router.g.dart';

/// Every route path in the app, in one place.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const groups = '/groups';
  static const groupDetail = '/groups/:id';
  static const rideDetail = '/rides/:id';
  static const rideMap = '/rides/:id/map';
  static const emergencyContacts = '/emergency-contacts';
  static const vehicles = '/vehicles';
  static const history = '/history';
  static const accidentDetail = '/accidents/:id';

  static String groupDetailPath(String id) => '/groups/$id';
  static String rideDetailPath(String id) => '/rides/$id';
  static String rideMapPath(String id) => '/rides/$id/map';
  static String accidentDetailPath(String id) => '/accidents/$id';
}

/// Bridges a `Stream` to go_router's `Listenable`-based `refreshListenable`,
/// so route guards re-evaluate whenever the Supabase auth session changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refreshStream = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges,
  );
  ref.onDispose(refreshStream.dispose);

  // The five "hub" screens (Fase 10's web dashboard gets a persistent
  // NavigationRail around exactly these). Defined once and reused by
  // whichever branch below actually wires them in, so the route
  // definitions themselves never differ between platforms — only whether
  // they're wrapped in a ShellRoute.
  final hubRoutes = [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.groups,
      builder: (context, state) => const GroupsPage(),
    ),
    GoRoute(
      path: AppRoutes.vehicles,
      builder: (context, state) => const VehiclesPage(),
    ),
    GoRoute(
      path: AppRoutes.emergencyContacts,
      builder: (context, state) => const EmergencyContactsPage(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryPage(),
    ),
  ];

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authRepositoryProvider).currentUser != null;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      // Web only: everywhere else (Android, and `flutter test`'s default
      // platform — see docs/architecture.md) gets the hub routes exactly
      // as they've always been, no shell, no behavior change at all.
      if (PlatformCapabilities.isWeb)
        ShellRoute(
          builder: (context, state, child) => AdaptiveShell(child: child),
          routes: hubRoutes,
        )
      else
        ...hubRoutes,
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.groupDetail,
        builder: (context, state) =>
            GroupDetailPage(groupId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.rideDetail,
        builder: (context, state) =>
            RideSessionPage(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.rideMap,
        builder: (context, state) =>
            RideMapPage(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.accidentDetail,
        builder: (context, state) =>
            AccidentDetailPage(accidentId: state.pathParameters['id']!),
      ),
    ],
  );
}
