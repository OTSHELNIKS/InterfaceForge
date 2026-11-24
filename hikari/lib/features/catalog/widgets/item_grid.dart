import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/hikari_item.dart';
import 'package:hikari/features/catalog/widgets/item_card.dart';
import 'package:hikari/core/theme/app_text.dart';

/// Сетка работ каталога (sliver).
class ItemGrid extends StatelessWidget {
  const ItemGrid({
    super.key,
    required this.items,
    required this.data,
    this.padding = const EdgeInsets.fromLTRB(24, 8, 24, 32),
    this.maxCrossAxisExtent = 300,
    this.spacing = 18,
    this.childAspectRatio = 0.70,
  });

  final List<HikariItem> items;
  final CatalogData data;
  final EdgeInsets padding;
  final double maxCrossAxisExtent;
  final double spacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            final collection = data.collectionById(item.collectionId);
            return ItemCard(
              item: item,
              collectionName: collection?.name ?? '',
              collectionJa: collection?.nameJa ?? '',
              collectionColor: collection?.color ?? AppColors.vermilion,
              onTap: () => context.push('/item/${item.id}'),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

/// Плашка «ничего не найдено» для каталога.
class NoResults extends StatelessWidget {
  const NoResults({super.key, required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: _NoResultsView(onReset: onReset),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 30,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Ничего не найдено', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Попробуйте другое слово, тег или HEX-цвет.',
            style: AppText.body(13.5, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded, size: 16),
            label: const Text('Сбросить фильтры'),
          ),
        ],
      ),
    );
  }
}
