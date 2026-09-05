import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel_v2/app/adaptive_shell.dart';
import 'package:sentinel_v2/app/hub_navigation.dart' show hubRailBreakpoint;
import 'package:sentinel_v2/app/router.dart' show AppRoutes;

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AdaptiveShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const Scaffold(body: Text('Home content')),
          ),
          GoRoute(
            path: AppRoutes.groups,
            builder: (context, state) =>
                const Scaffold(body: Text('Groups content')),
          ),
        ],
      ),
    ],
  );
}

Future<void> _pumpAtWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp.router(routerConfig: _testRouter()));
  await tester.pumpAndSettle();
}

void main() {
  group('AdaptiveShell', () {
    testWidgets('renders the page with no rail below the breakpoint', (
      tester,
    ) async {
      await _pumpAtWidth(tester, hubRailBreakpoint - 1);

      expect(find.text('Home content'), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('shows a NavigationRail at/above the breakpoint', (
      tester,
    ) async {
      await _pumpAtWidth(tester, hubRailBreakpoint);

      expect(find.text('Home content'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('highlights the destination matching the current route', (
      tester,
    ) async {
      await _pumpAtWidth(tester, 1200);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));

      expect(rail.selectedIndex, 0); // Inicio
    });

    testWidgets('tapping a destination navigates via go_router', (
      tester,
    ) async {
      await _pumpAtWidth(tester, 1200);

      await tester.tap(find.text('Grupos'));
      await tester.pumpAndSettle();

      expect(find.text('Groups content'), findsOneWidget);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.selectedIndex, 1); // Grupos
    });
  });
}
