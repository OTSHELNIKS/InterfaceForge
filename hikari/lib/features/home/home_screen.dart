import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/data/models/catalog_filters.dart';
import 'package:hikari/data/models/hikari_item.dart';

const double _designWidth = 1223;
const double _designHeight = 1286;
const String _designAsset = 'assets/design/hikari-light-concept.png';

const List<String> _fallbackItemIds = <String>[
  'akane-no-sora',
  'vermilion-dusk',
  'kintoki',
  'hinomaru',
  'yozakura',
  'somei-yoshino',
  'hanafubuki',
  'sakura-no-uta',
  'sumi-no-mai',
  'kurogane',
  'ink-and-gold',
  'kannon',
  'ai-no-kawa',
  'ruri',
  'seigaiha',
  'asanoha',
];

const List<String> _fallbackCollectionIds = <String>[
  'akane',
  'sakura',
  'sumi',
  'aoi',
];

const List<String> _cardLabels = <String>[
  'Утро в Киото',
  'Красные клёны',
  'Тихий храм',
  'Фудзи на рассвете',
  'Улицы Токио',
  'Весеннее отражение',
  'Путь фонарей',
  'Зимняя тишина',
  'Одинокое дерево',
  'Золотой вечер',
  'Волны',
  'Ночной Токио',
  'Поле цветов',
  'Снежный храм',
  'Бамбуковая роща',
  'Осенний мост',
];

const List<double> _cardX = <double>[209, 393, 573, 756];
const List<double> _cardW = <double>[173, 170, 172, 175];
const List<double> _cardY = <double>[638, 787, 936, 1086];
const List<double> _cardH = <double>[99, 100, 100, 100];

const List<double> _topTabX = <double>[780, 835, 890, 955];
const List<double> _topTabW = <double>[55, 55, 65, 50];
const List<String> _topTabLabels = <String>['Обзор', 'Темы', 'Авторы', 'Теги'];
const List<String> _topTabRoutes = <String>[
  '/home',
  '/settings',
  '/catalog',
  '/catalog',
];

const List<String> _sideLabels = <String>[
  'Главная',
  'Каталог',
  'Коллекции',
  'Темы интерфейса',
  'Избранное',
];
const List<String> _sideRoutes = <String>[
  '/home',
  '/catalog',
  '/catalog',
  '/settings',
  '/favorites',
];
const List<String> _infoLabels = <String>['О нас', 'Блог', 'Помощь'];

const List<double> _collectionX = <double>[207, 461, 715, 969];
const List<double> _collectionW = <double>[238, 238, 238, 232];
const List<String> _collectionLabels = <String>[
  'Сезоны Японии',
  'Города и улицы',
  'Интерьеры',
  'Классика и искусство',
];

const List<double> _filterX = <double>[
  208,
  258,
  335,
  405,
  470,
  568,
  660,
  752,
  812,
  872,
];
const List<double> _filterW = <double>[
  42,
  70,
  62,
  56,
  90,
  84,
  84,
  52,
  52,
  52,
];
const List<String> _filterLabels = <String>[
  'Все',
  'Природа',
  'Города',
  'Аниме',
  'Минимализм',
  'Искусство',
  'Интерьеры',
  'Ночь',
  'Зима',
  'Лето',
];
const List<String> _filterQueries = <String>[
  '',
  'природа',
  'город',
  'аниме',
  'минимализм',
  'искусство',
  'интерьер',
  'ночь',
  'зима',
  'лето',
];
const List<double> _similarX = <double>[965, 1070, 1125];

/// Главная на GitHub Pages: пиксельно точный выбранный макет 1:1.
///
/// Фон — тот же PNG, который выбрал пользователь. Поверх него расположены
/// прозрачные интерактивные зоны: меню, поиск, hero, коллекции, 16 карточек,
/// избранное и правая панель. Так страница выглядит «в пиксель», но остаётся
/// рабочим Flutter-приложением catalog/detail/settings/favorites.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(catalogProvider).asData?.value;
    final items = data?.items ?? const <HikariItem>[];
    final collectionIds =
        data?.collections.map((collection) => collection.id).toList() ??
            _fallbackCollectionIds;
    final featuredId = _itemId(items, 3);

    return Scaffold(
      backgroundColor: AppColors.designPaper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < _designWidth
              ? constraints.maxWidth
              : _designWidth;
          final height = width * _designHeight / _designWidth;
          return SingleChildScrollView(
            primary: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                height: height,
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: _designWidth,
                    height: _designHeight,
                    child: _canvas(items, collectionIds, featuredId),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _canvas(
    List<HikariItem> items,
    List<String> collectionIds,
    String featuredId,
  ) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            _designAsset,
            width: _designWidth,
            height: _designHeight,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
        ),
        _zone(208, 60, 993, 266, 'Открыть каталог', () {
          _openCatalog(popular: true);
        }),
        _zone(255, 267, 197, 42, 'Открыть коллекции', () {
          _openCatalog(popular: true);
        }),
        _zone(210, 10, 410, 44, 'Поиск по каталогу', () {
          _openSearch();
        }),
        for (var i = 0; i < _topTabLabels.length; i++)
          _zone(
            _topTabX[i],
            10,
            _topTabW[i],
            44,
            _topTabLabels[i],
            () => _go(_topTabRoutes[i]),
          ),
        _zone(1060, 10, 40, 44, 'Оформление', () => _go('/settings')),
        _zone(1090, 10, 35, 44, 'Акцент', () => _go('/settings')),
        _zone(1135, 10, 55, 44, 'Язык и настройки', () => _go('/settings')),
        _zone(20, 25, 170, 130, 'Hikari · на главную', () => _go('/home')),
        for (var i = 0; i < _sideLabels.length; i++)
          _zone(
            10,
            160 + 36 * i.toDouble(),
            180,
            36,
            _sideLabels[i],
            () => _go(_sideRoutes[i]),
          ),
        for (var i = 0; i < _infoLabels.length; i++)
          _zone(
            10,
            380 + 30 * i.toDouble(),
            180,
            30,
            _infoLabels[i],
            () => _go('/settings'),
          ),
        _zone(45, 1150, 50, 50, 'Hikari · 光', () => _go('/home')),
        _zone(1105, 345, 100, 30, 'Смотреть все коллекции', () {
          _openCatalog(popular: true);
        }),
        for (var i = 0; i < _collectionLabels.length; i++)
          _zone(
            _collectionX[i],
            386,
            _collectionW[i],
            154,
            'Коллекция: ${_collectionLabels[i]}',
            () => _openCatalog(
              collection: _collectionId(collectionIds, i),
              popular: true,
            ),
          ),
        _zone(805, 568, 140, 30, 'Сортировка: по популярности', () {
          _openCatalog(popular: true);
        }),
        for (var i = 0; i < _filterLabels.length; i++)
          _zone(
            _filterX[i],
            598,
            _filterW[i],
            28,
            'Фильтр: ${_filterLabels[i]}',
            () => _openCatalog(query: _filterQueries[i], popular: true),
          ),
        ..._cardZones(items),
        _zone(
          955,
          576,
          243,
          664,
          'Фудзи на рассвете — подробнее',
          () => _openItem(featuredId),
        ),
        ..._heartZones(items),
        _zone(1145, 588, 40, 40, 'В избранное: Фудзи на рассвете', () {
          _toggleFavorite(featuredId, 'Фудзи на рассвете');
        }),
        _zone(962, 1098, 186, 36, 'Применить обои', () {
          _openItem(featuredId);
        }),
        for (var i = 0; i < _similarX.length; i++)
          _zone(
            _similarX[i],
            1170,
            52,
            52,
            'Похожие обои ${i + 1}',
            () => _openItem(_itemId(items, i)),
          ),
      ],
    );
  }

  List<Positioned> _cardZones(List<HikariItem> items) {
    final zones = <Positioned>[];
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        final index = row * 4 + col;
        zones.add(
          _zone(
            _cardX[col],
            _cardY[row],
            _cardW[col],
            _cardH[row],
            _cardLabels[index],
            () => _openItem(_itemId(items, index)),
          ),
        );
      }
    }
    return zones;
  }

  List<Positioned> _heartZones(List<HikariItem> items) {
    final zones = <Positioned>[];
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        final index = row * 4 + col;
        zones.add(
          _zone(
            _cardX[col] + _cardW[col] - 32,
            _cardY[row] + 6,
            28,
            28,
            'В избранное: ${_cardLabels[index]}',
            () => _toggleFavorite(_itemId(items, index), _cardLabels[index]),
          ),
        );
      }
    }
    return zones;
  }

  Positioned _zone(
    double x,
    double y,
    double width,
    double height,
    String label,
    VoidCallback onTap,
  ) {
    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: Tooltip(
        message: label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Semantics(
            button: true,
            label: label,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }

  static String _itemId(List<HikariItem> items, int index) {
    return index < items.length
        ? items[index].id
        : _fallbackItemIds[index % _fallbackItemIds.length];
  }

  static String _collectionId(List<String> ids, int index) {
    return index < ids.length
        ? ids[index]
        : _fallbackCollectionIds[index % _fallbackCollectionIds.length];
  }

  void _go(String route) => context.go(route);

  void _openItem(String id) => context.push('/item/$id');

  void _openCatalog({String? query, String? collection, bool popular = false}) {
    final filters = ref.read(catalogFiltersProvider.notifier);
    filters.reset();
    if (query != null && query.isNotEmpty) filters.setQuery(query);
    if (collection != null) filters.setCollection(collection);
    if (popular) filters.setSort(CatalogSort.popular);
    context.go('/catalog');
  }

  Future<void> _openSearch() async {
    _search.clear();
    final query = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Поиск по каталогу'),
        content: TextField(
          controller: _search,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Поиск обоев, тем, тегов...',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(_search.text),
            child: const Text('Найти'),
          ),
        ],
      ),
    );
    if (!mounted || query == null) return;
    _openCatalog(query: query.trim(), popular: true);
  }

  void _toggleFavorite(String id, String label) {
    final wasFavorite = ref.read(favoritesProvider).contains(id);
    ref.read(favoritesProvider.notifier).toggle(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? '$label удалено из избранного'
              : '$label добавлено в избранное',
        ),
      ),
    );
  }
}

/// Состояние загрузки каталога.
class CatalogLoading extends StatelessWidget {
  const CatalogLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KanjiMark(
            size: 96,
            color: theme.colorScheme.primary,
            opacity: 0.18,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Собираем свет…',
            style: AppText.body(13, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Состояние ошибки каталога.
class CatalogError extends StatelessWidget {
  const CatalogError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 34, color: AppColors.vermilion),
            const SizedBox(height: 16),
            Text('Каталог не загрузился', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body(13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
