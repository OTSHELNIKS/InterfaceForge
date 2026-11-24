import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/core/widgets/page_container.dart';
import 'package:hikari/features/home/home_screen.dart';
import 'package:hikari/features/catalog/widgets/filter_bar.dart';
import 'package:hikari/features/catalog/widgets/item_grid.dart';
import 'package:hikari/features/catalog/widgets/search_field.dart';
import 'package:hikari/core/widgets/sakura_branch.dart';

/// Каталог: поиск, фильтры, сортировка и сетка работ.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final items = ref.watch(filteredItemsProvider);

    // При смене фильтра возвращаемся к началу списка.
    ref.listen(catalogFiltersProvider.select((f) => (f.type, f.collection, f.sort)), (
      previous,
      next,
    ) {
      if (previous != next && _controller.hasClients) {
        _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return catalog.when(
      loading: () => const CatalogLoading(),
      error: (error, stack) => CatalogError(
        message: 'Не удалось прочитать каталог: $error',
        onRetry: () => ref.invalidate(catalogProvider),
      ),
      data: (data) => PageContainer(
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.paddingOf(context).top + 18),
            ),
            SliverToBoxAdapter(
              child: _CatalogHeader(total: data.items.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: HikariSearchField(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: FilterBar(data: data)),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            items.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 1.6)),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: CatalogError(
                  message: 'Ошибка фильтрации: $error',
                  onRetry: () => ref.invalidate(catalogProvider),
                ),
              ),
              data: (list) => list.isEmpty
                  ? NoResults(
                      onReset: () =>
                          ref.read(catalogFiltersProvider.notifier).reset(),
                    )
                  : ItemGrid(items: list, data: data),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 112)),
          ],
        ),
      ),
    );
  }
}

class _CatalogHeader extends ConsumerWidget {
  const _CatalogHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(catalogFiltersProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
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
                    Text('КАТАЛОГ · 光', style: AppText.eyebrow(AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  filters.query.trim().isEmpty ? 'Каталог' : 'Результаты',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width >= 880 ? 44 : 34,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$total ${_plural(total)} · 4 коллекции · темы и обои',
                  style: AppText.body(
                    13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 880)
            KanjiMark(
              size: 110,
              color: theme.colorScheme.primary,
              opacity: 0.10,
            ),
        ],
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
