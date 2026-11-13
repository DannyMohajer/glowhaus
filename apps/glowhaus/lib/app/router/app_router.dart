import 'package:flutter/material.dart';
import 'package:glowhaus/app/app_shell.dart';
import 'package:glowhaus/app/router/routes.dart';
import 'package:glowhaus/features/dashboard/view/dashboard_screen.dart';
import 'package:glowhaus/features/rooms/view/rooms_panes.dart';
import 'package:glowhaus/features/settings/view/settings_screen.dart';
import 'package:glowhaus/features/welcome/view/welcome_screen.dart';
import 'package:glowhaus_ui/glowhaus_ui.dart';
import 'package:go_router/go_router.dart';

/// The one navigation system.
///
/// ```text
/// /welcome
/// shell (bottom nav or side rail)
///   /home
///   /demo                                 home with the devices panel open
///   /rooms                                rooms
///   /rooms/:roomId                        rooms | room
///   /rooms/:roomId/devices/:deviceId      rooms | room | device
///   /settings
/// ```
///
/// The three room routes render the same [RoomsPanes]; how many panes are
/// visible depends on the window width, not on the route.
GoRouter createRouter({String initialLocation = Routes.welcome}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', redirect: (_, _) => Routes.welcome),
    GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: Routes.home, pageBuilder: (_, _) => _dashboardPage),
            // The same page, so the dashboard stays put while the address
            // follows the devices panel (see AppShell).
            GoRoute(path: Routes.demo, pageBuilder: (_, _) => _dashboardPage),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.rooms,
              pageBuilder: (context, state) =>
                  _panesPage(context, state, const RoomsPanes()),
              routes: [
                GoRoute(
                  path: ':roomId',
                  pageBuilder: (context, state) => _panesPage(
                    context,
                    state,
                    RoomsPanes(roomId: state.pathParameters['roomId']),
                  ),
                  routes: [
                    GoRoute(
                      path: 'devices/:deviceId',
                      pageBuilder: (context, state) => _panesPage(
                        context,
                        state,
                        RoomsPanes(
                          roomId: state.pathParameters['roomId'],
                          deviceId: state.pathParameters['deviceId'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

const Page<void> _dashboardPage = NoTransitionPage<void>(
  key: ValueKey('dashboard'),
  child: DashboardScreen(),
);

/// On phones each step is a page with a transition and a back gesture. On
/// wider windows the panes update in place, so the page change is instant.
Page<void> _panesPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) => GlowWindowSize.of(context) == GlowWindowSize.compact
    ? MaterialPage<void>(key: state.pageKey, child: child)
    : NoTransitionPage<void>(key: state.pageKey, child: child);
