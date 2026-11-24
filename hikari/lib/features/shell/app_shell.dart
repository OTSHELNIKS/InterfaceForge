import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/core/constants/app_constants.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/grain_overlay.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/core/widgets/paper_background.dart';

class HikariDestination {
  const HikariDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<HikariDestination> kDestinations = [
  HikariDestination(
    label: 'Обзор',
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome_rounded,
  ),
  HikariDestination(
    label: 'Каталог',
    icon: Icons.grid_view_rounded,
    selectedIcon: Icons.grid_view_rounded,
  ),
  HikariDestination(
    label: 'Избранное',
    icon: Icons.favorite_outline_rounded,
    selectedIcon: Icons.favorite_rounded,
  ),
  HikariDestination(
    label: 'Настройки',
    icon: Icons.tune_rounded,
    selectedIcon: Icons.tune_rounded,
  ),
];

/// Адаптивная оболочка: NavigationRail на ПК, плавающая «таблетка» на телефоне.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final rail = width >= 900;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Главная — пиксельно точный макет 1:1: ни рейла, ни нижней навигации,
    // ни дополнительного PaperBackground поверх выбранного PNG.
    final exactHome = navigationShell.currentIndex == 0;
    final uiDark = dark && !exactHome;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: uiDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: uiDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: uiDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        extendBody: !rail && !exactHome,
        backgroundColor: exactHome
            ? AppColors.designPaper
            : Theme.of(context).scaffoldBackgroundColor,
        body: exactHome
            ? navigationShell
            : PaperBackground(
                child: Row(
                  children: [
                    if (rail) HikariRail(shell: navigationShell, extended: width >= 1180),
                    Expanded(child: navigationShell),
                  ],
                ),
              ),
        bottomNavigationBar: rail || exactHome
            ? null
            : HikariBottomNav(shell: navigationShell),
      ),
    );
  }
}

/// Плавающая нижняя навигация в виде «таблетки».
class HikariBottomNav extends StatelessWidget {
  const HikariBottomNav({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final dark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: (dark ? AppColors.sumiCard : AppColors.card).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sumi.withValues(alpha: dark ? 0.5 : 0.12),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < kDestinations.length; i++)
                  Expanded(
                    child: _BottomDestination(
                      destination: kDestinations[i],
                      selected: i == shell.currentIndex,
                      accent: accent,
                      onTap: () => shell.goBranch(
                        i,
                        initialLocation: i == shell.currentIndex,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomDestination extends StatelessWidget {
  const _BottomDestination({
    required this.destination,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final HikariDestination destination;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 54,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: selected ? accent.withValues(alpha: 0.13) : Colors.transparent,
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 21,
                color: selected ? accent : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppText.label(
                9.5,
                color: selected ? accent : theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.02,
              ),
              child: Text(destination.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Боковая навигация для ПК.
class HikariRail extends StatelessWidget {
  const HikariRail({
    super.key,
    required this.shell,
    required this.extended,
  });

  final StatefulNavigationShell shell;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      width: extended ? 250 : 88,
      decoration: BoxDecoration(
        color: (dark ? AppColors.sumiDeep : AppColors.paper).withValues(alpha: 0.55),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            SizedBox(
              height: 64,
              child: Center(
                child: extended
                    ? const HikariLogo(size: 29)
                    : const HikariLogo(size: 26, showKanji: false),
              ),
            ),
            const SizedBox(height: 22),
            if (extended)
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 10),
                child: Text(
                  'НАВИГАЦИЯ',
                  style: AppText.eyebrow(
                    theme.colorScheme.onSurfaceVariant,
                    size: 9.5,
                  ),
                ),
              ),
            for (var i = 0; i < kDestinations.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: _RailDestination(
                  destination: kDestinations[i],
                  selected: i == shell.currentIndex,
                  extended: extended,
                  accent: accent,
                  onTap: () => shell.goBranch(
                    i,
                    initialLocation: i == shell.currentIndex,
                  ),
                ),
              ),
            const Spacer(),
            if (extended)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: dark ? AppColors.sumiCard : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.vermilion, AppColors.vermilionLight],
                        ),
                      ),
                      child: const Text(
                        '光',
                        style: TextStyle(
                          fontFamily: 'YujiSyuku',
                          fontSize: 22,
                          color: AppColors.card,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: AppText.brush(
                              20,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'v${AppConstants.version}',
                            style: AppText.label(
                              10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Center(
                  child: Text(
                    '1.0',
                    style: AppText.label(
                      9.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailDestination extends StatelessWidget {
  const _RailDestination({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.accent,
    required this.onTap,
  });

  final HikariDestination destination;
  final bool selected;
  final bool extended;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
      ),
      child: extended
          ? Row(
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 21,
                  color: selected ? accent : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Text(
                  destination.label,
                  style: AppText.body(
                    14,
                    weight: FontWeight.w500,
                    color: selected ? accent : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            )
          : Center(
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 22,
                color: selected ? accent : theme.colorScheme.onSurfaceVariant,
              ),
            ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Tooltip(
        message: destination.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: content,
        ),
      ),
    );
  }
}

/// Лёгкая текстура поверх всего окна (используется в корне).
class GlobalGrain extends StatelessWidget {
  const GlobalGrain({super.key, required this.child, this.opacity = 0.02});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: GrainOverlay(opacity: opacity),
          ),
        ),
      ],
    );
  }
}
