import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/features/website/website.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => WebsiteShell(location: state.uri.path, child: child),
      routes: <RouteBase>[
        GoRoute(path: '/home', builder: (context, state) => const WebsiteHome()),
        GoRoute(path: '/catalog', builder: (context, state) => WebsiteCatalog(uri: state.uri)),
        GoRoute(path: '/wallpapers', builder: (context, state) => WallpaperCatalog(uri: state.uri)),
        GoRoute(path: '/wallpapers/:id', builder: (context, state) => WallpaperDetail(id: state.pathParameters['id']!)),
        GoRoute(path: '/collections', builder: (context, state) => const WebsiteCollections()),
        GoRoute(path: '/favorites', builder: (context, state) => const WebsiteCatalog(favoritesOnly: true)),
        GoRoute(path: '/item/:id', builder: (context, state) => WebsiteDetail(id: state.pathParameters['id']!)),
        GoRoute(path: '/about', builder: (context, state) => const WebsiteAbout()),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(body: Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const Text('Страница не найдена'),
      TextButton(onPressed: () => context.go('/home'), child: const Text('На главную')),
    ],
  ))),
));
