import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/features/catalog/catalog_screen.dart';
import 'package:hikari/features/detail/detail_screen.dart';
import 'package:hikari/features/favorites/favorites_screen.dart';
import 'package:hikari/features/home/home_screen.dart';
import 'package:hikari/features/settings/settings_screen.dart';
import 'package:hikari/features/shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'hikari-root');

/// Маршрутизация: StatefulShellRoute с сохранением состояния вкладок.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: false,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                name: 'catalog',
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/item/:id',
        name: 'detail',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 380),
            reverseTransitionDuration: const Duration(milliseconds: 280),
            child: DetailScreen(itemId: id),
            transitionsBuilder: (context, animation, secondary, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.035),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 38, color: AppColors.vermilion),
            const SizedBox(height: 14),
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
});
