import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/constants/app_constants.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/core/widgets/page_container.dart';
import 'package:hikari/core/widgets/paper_background.dart';
import 'package:hikari/core/widgets/sakura_branch.dart';
import 'package:hikari/data/models/device_info.dart';
import 'package:hikari/data/models/hikari_item.dart';

/// Настройки: режим, активная тема, устройство и сведения о приложении.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = ref.watch(deviceInfoProvider).asData?.value;
    final active = ref.watch(activeThemeProvider);
    final mode = ref.watch(themeModeProvider);

    return PageContainer(
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).top + 18),
          ),
          SliverToBoxAdapter(child: _Header()),
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: 'Оформление',
              subtitle: 'Как приложение выглядит на этом устройстве',
              child: _ModeSelector(mode: mode),
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: 'Активная тема',
              subtitle: 'Палитра, которую вы применили последней',
              child: _ActiveThemeCard(active: active),
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: 'Устройство',
              subtitle: 'Платформа и сведения о системе',
              child: _DeviceCard(info: device),
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: 'О приложении',
              subtitle: 'Hikari — темы и обои в духе японской эстетики',
              child: const _AboutCard(),
            ),
          ),
          SliverToBoxAdapter(child: _Footer(onReset: _resetAll)),
          const SliverToBoxAdapter(child: SizedBox(height: 112)),
        ],
      ),
    );
  }

  Future<void> _resetAll() async {
    await ref.read(activeThemeIdProvider.notifier).set(null);
    await ref.read(themeModeProvider.notifier).set(ThemeMode.system);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки оформления сброшены')),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const GoldRule(width: 34),
                    const SizedBox(width: 12),
                    Text('НАСТРОЙКИ · 設定', style: AppText.eyebrow(AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Настройки',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width >= 880 ? 44 : 34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Свет, палитра и устройство — всё в одном месте.',
                  style: AppText.body(13, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 880)
            const HikariLogo(size: 26, showKanji: false),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(width: 10),
                Text(
                  '·',
                  style: AppText.body(13, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subtitle,
                    style: AppText.body(
                      12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sumi.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = [
      (ThemeMode.system, 'Системный', Icons.brightness_auto_rounded),
      (ThemeMode.light, 'Светлый', Icons.light_mode_rounded),
      (ThemeMode.dark, 'Тёмный', Icons.dark_mode_rounded),
    ];
    return Row(
      children: [
        for (final (value, label, icon) in tiles) ...[
          Expanded(
            child: _ModeTile(
              icon: icon,
              label: label,
              selected: mode == value,
              onTap: () => ref.read(themeModeProvider.notifier).set(value),
            ),
          ),
          if (value != ThemeMode.dark) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.55)
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? accent.withValues(alpha: 0.14)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected ? accent : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  label,
                  style: AppText.body(
                    12,
                    weight: FontWeight.w500,
                    color: selected ? accent : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selected ? 1 : 0,
                  child: Icon(Icons.check_circle_rounded, size: 13, color: accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveThemeCard extends ConsumerWidget {
  const _ActiveThemeCard({required this.active});

  final HikariItem? active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final item = active;
    final colors = item?.colors ??
        const [
          AppColors.sumi,
          AppColors.vermilion,
          AppColors.vermilionLight,
          AppColors.sakura,
          AppColors.gold,
        ];

    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.first, colors[1]],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              item?.titleJa ?? '光',
              style: TextStyle(
                fontFamily: item?.titleJa != null ? 'ShipporiMincho' : 'YujiSyuku',
                fontSize: 22,
                color: AppColors.card,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item?.title ?? 'Фирменная палитра',
                style: AppText.display(19, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 3),
              Text(
                item != null ? '${item.type.label} · ${item.collectionId}' : 'Hikari · киноварь и бумага',
                style: AppText.body(
                  12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              PaletteStrip(colors: colors, size: 22),
            ],
          ),
        ),
        if (item != null)
          TextButton(
            onPressed: () => ref.read(activeThemeIdProvider.notifier).set(null),
            child: const Text('Сбросить'),
          ),
      ],
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  const _DeviceCard({required this.info});

  final DeviceInfo? info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = info;
    return Column(
      children: [
        _InfoRow(
          icon: Icons.devices_rounded,
          label: 'Платформа',
          value: device?.platform ?? '—',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.memory_rounded,
          label: 'Версия',
          value: device?.version ?? '—',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.phone_android_rounded,
          label: 'Модель',
          value: device?.model ?? '—',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.wallpaper_rounded,
          label: 'Системные обои',
          value: (device?.wallpaperSupported ?? false) ? 'Доступны' : 'Недоступны',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppText.body(13.5, color: theme.colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppText.body(
                13.5,
                weight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.info_outline_rounded,
          label: 'Версия',
          value: '${AppConstants.version} (${AppConstants.build})',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.font_download_outlined,
          label: 'Шрифты',
          value: 'Yuji Syuku · Caveat Brush · Shippori Mincho · Playfair',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.verified_outlined,
          label: 'Лицензии',
          value: 'OFL 1.1 · шрифты Google Fonts',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.favorite_outline_rounded,
          label: 'Сделано',
          value: 'с уважением к японской эстетике',
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          const HikariLogo(size: 26),
          const SizedBox(height: 10),
          Text(
            'Hikari · 光 · ${DateTime.now().year}',
            style: AppText.label(
              10,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.22,
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 15),
            label: const Text('Сбросить оформление'),
          ),
        ],
      ),
    );
  }
}
