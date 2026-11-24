import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/catalog_filters.dart';
import 'package:hikari/data/models/hikari_item.dart';

/// Фильтры по типу и коллекции + сортировка.
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key, required this.data, this.padding = 24});

  final CatalogData data;
  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            children: [
              _HikariChip(
                label: 'Все',
                icon: Icons.layers_outlined,
                selected: filters.type == null,
                accent: accent,
                onTap: () =>
                    ref.read(catalogFiltersProvider.notifier).setType(null),
              ),
              const SizedBox(width: 8),
              _HikariChip(
                label: 'Темы',
                icon: Icons.palette_outlined,
                selected: filters.type == HikariItemType.theme,
                accent: accent,
                onTap: () => ref
                    .read(catalogFiltersProvider.notifier)
                    .setType(HikariItemType.theme),
              ),
              const SizedBox(width: 8),
              _HikariChip(
                label: 'Обои',
                icon: Icons.wallpaper_rounded,
                selected: filters.type == HikariItemType.wallpaper,
                accent: accent,
                onTap: () => ref
                    .read(catalogFiltersProvider.notifier)
                    .setType(HikariItemType.wallpaper),
              ),
              const SizedBox(width: 8),
              _SortChip(filters: filters, accent: accent),
              if (!filters.isEmpty) ...[
                const SizedBox(width: 8),
                _ResetChip(accent: accent),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            children: [
              _HikariChip(
                label: 'Все коллекции',
                icon: Icons.apps_rounded,
                selected: filters.collection == null,
                accent: accent,
                onTap: () =>
                    ref.read(catalogFiltersProvider.notifier).setCollection(null),
              ),
              for (final collection in data.collections) ...[
                const SizedBox(width: 8),
                _HikariChip(
                  label: collection.name,
                  subLabel: collection.nameJa,
                  dot: collection.color,
                  selected: filters.collection == collection.id,
                  accent: accent,
                  onTap: () => ref
                      .read(catalogFiltersProvider.notifier)
                      .setCollection(collection.id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HikariChip extends StatelessWidget {
  const _HikariChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.icon,
    this.subLabel,
    this.dot,
  });

  final String label;
  final String? subLabel;
  final IconData? icon;
  final Color? dot;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? accent.withValues(alpha: 0.11)
                : theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.45)
                  : theme.colorScheme.outline.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dot != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dot,
                    boxShadow: [
                      BoxShadow(
                        color: dot!.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? accent : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: AppText.body(
                  13,
                  weight: FontWeight.w500,
                  color: selected ? accent : theme.colorScheme.onSurface,
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(width: 6),
                Text(
                  subLabel!,
                  style: AppText.mincho(
                    11,
                    color: (selected ? accent : theme.colorScheme.onSurfaceVariant)
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends ConsumerWidget {
  const _SortChip({required this.filters, required this.accent});

  final CatalogFilters filters;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return PopupMenuButton<CatalogSort>(
      tooltip: 'Сортировка',
      position: PopupMenuPosition.under,
      onSelected: ref.read(catalogFiltersProvider.notifier).setSort,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: theme.colorScheme.surfaceContainerLowest,
      itemBuilder: (context) => [
        for (final sort in CatalogSort.values)
          PopupMenuItem<CatalogSort>(
            value: sort,
            child: Row(
              children: [
                Icon(
                  sort.icon,
                  size: 17,
                  color: sort == filters.sort ? accent : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  sort.label,
                  style: AppText.body(
                    13,
                    weight: sort == filters.sort ? FontWeight.w600 : FontWeight.w400,
                    color: sort == filters.sort ? accent : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_vert_rounded,
              size: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              filters.sort.label,
              style: AppText.body(13, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetChip extends ConsumerWidget {
  const _ResetChip({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => ref.read(catalogFiltersProvider.notifier).reset(),
      icon: const Icon(Icons.restart_alt_rounded, size: 15),
      label: const Text('Сбросить'),
      style: TextButton.styleFrom(
        foregroundColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: AppText.body(12.5, color: accent),
      ),
    );
  }
}

/// Счётчик результатов.
class ResultsCount extends ConsumerWidget {
  const ResultsCount({super.key, required this.total, this.padding = 24});

  final int total;
  final double padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    final theme = Theme.of(context);
    final label = filters.isEmpty
        ? '$total ${_plural(total)}'
        : '${filters.query.trim().isEmpty ? '' : '«${filters.query.trim()}» · '}$total ${_plural(total)}';
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 2, padding, 12),
      child: Text(
        label,
        style: AppText.body(
          12,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.02,
        ),
      ),
    );
  }
}

String _plural(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return 'работа';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return 'работы';
  return 'работ';
}
