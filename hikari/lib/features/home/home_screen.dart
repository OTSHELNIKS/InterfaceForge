import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/data/models/catalog_filters.dart';
import 'package:hikari/features/home/design_data.dart';

const double _designWidth = 1223;
const double _designHeight = 1286;

const Color _paper = Color(0xFFF2EDE3);
const Color _card = Color(0xFFFCF8F2);
const Color _chip = Color(0xFFEFE9E0);
const Color _muted = Color(0xFF8C7F75);
const Color _body = Color(0xFF6B5E54);
const Color _ink = Color(0xFF1E1917);
const Color _heroText = Color(0xFFF4E8DE);

const List<double> _filterW = <double>[42, 70, 62, 56, 90, 84, 84, 52, 52, 52];

String _sortLabel(CatalogSort sort) {
  switch (sort) {
    case CatalogSort.popular:
      return 'Популярные';
    case CatalogSort.newest:
      return 'Сначала новые';
    case CatalogSort.alphabetical:
      return 'По алфавиту';
  }
}

const List<String> kSideKanji = <String>[
  '光',
  'は',
  'い',
  'つ',
  'も',
  'そ',
  'こ',
  'に',
  'あ',
  'る',
];
const String kHeroKanji = '美\nは\n、\n日\n常\nの\n中\nに\nあ\nる';

/// Главная GitHub Pages, собранная настоящими виджетами по выбранному макету.
///
/// В репозитории лежит только набор вырезанных графических элементов
/// (`assets/design/*`): фото hero, обложки коллекций, 16 миниатюр, декор.
/// Текст, поиск, фильтры, сетка, избранное и правая панель — реальные виджеты.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  double _scale = 1;
  int _selectedIndex = 3;
  String _query = '';
  String _filter = 'Все';
  int? _collection;
  bool _onlyFavorites = false;
  CatalogSort _sort = CatalogSort.popular;
  int _resolution = 0;
  int _similarOffset = 0;
  String _language = 'RU';
  Color _accent = AppColors.vermilion;
  Color _circleColor = AppColors.gold;

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final visible = _visibleItems(favorites);
    final selected = kDesignItems[_selectedIndex];

    return Scaffold(
      backgroundColor: _paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < _designWidth
              ? constraints.maxWidth
              : _designWidth;
          final height = width * _designHeight / _designWidth;
          _scale = width / _designWidth;
          return SingleChildScrollView(
            controller: _scroll,
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
                    child: _canvas(visible, favorites, selected),
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
    List<DesignItem> visible,
    Set<String> favorites,
    DesignItem selected,
  ) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: Container(color: _paper)),
        Positioned(
          left: 0,
          top: 0,
          width: 190,
          height: _designHeight,
          child: _sidebar(favorites),
        ),
        Positioned(
          left: 208,
          top: 10,
          width: 993,
          height: 44,
          child: _topbar(),
        ),
        Positioned(
          left: 208,
          top: 60,
          width: 993,
          height: 266,
          child: _hero(),
        ),
        Positioned(
          left: 208,
          top: 345,
          width: 993,
          height: 34,
          child: _overviewHeader(),
        ),
        Positioned(
          left: 207,
          top: 386,
          width: 994,
          height: 154,
          child: _collectionsRow(),
        ),
        Positioned(
          left: 208,
          top: 560,
          width: 600,
          height: 36,
          child: Text(
            'Каталог',
            style: AppText.display(26, color: _ink),
          ),
        ),
        Positioned(
          left: 805,
          top: 568,
          width: 140,
          height: 30,
          child: _sortButton(),
        ),
        Positioned(
          left: 208,
          top: 598,
          width: 723,
          height: 28,
          child: _filterChips(),
        ),
        Positioned(
          left: 208,
          top: 638,
          width: 723,
          height: 548,
          child: _grid(visible, favorites),
        ),
        Positioned(
          left: 955,
          top: 576,
          width: 243,
          height: 664,
          child: _detailPanel(selected, favorites),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Левая колонка
  // ---------------------------------------------------------------------------

  Widget _sidebar(Set<String> favorites) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: Container(color: _paper)),
        Positioned(
          left: 40,
          top: 15,
          width: 85,
          height: 65,
          child: Image.asset('assets/design/logo-bird.png', fit: BoxFit.contain),
        ),
        Positioned(
          left: 25,
          top: 78,
          width: 165,
          height: 38,
          child: Text(
            'Hikari · 光',
            style: AppText.display(28, color: _ink),
          ),
        ),
        Positioned(
          left: 25,
          top: 115,
          width: 160,
          height: 34,
          child: Text(
            'ЯПОНСКИЕ ОБОИ\nИ ТЕМЫ ИНТЕРФЕЙСА',
            style: AppText.label(9, color: _muted, letterSpacing: 0.16, height: 1.35),
          ),
        ),
        Positioned(
          left: 10,
          top: 160,
          width: 180,
          height: 180,
          child: Column(
            children: <Widget>[
              _sideNavItem(Icons.home_outlined, 'Главная', true, () {
                _onlyFavorites = false;
                _scrollTo(0);
              }),
              _sideNavItem(Icons.grid_view_outlined, 'Каталог', false, () {
                _onlyFavorites = false;
                _scrollTo(560);
              }),
              _sideNavItem(Icons.auto_awesome_outlined, 'Коллекции', false, () {
                _onlyFavorites = false;
                _scrollTo(345);
              }),
              _sideNavItem(Icons.tune_outlined, 'Темы интерфейса', false, _showThemeDialog),
              _sideNavItem(Icons.favorite_outline_rounded, 'Избранное', _onlyFavorites, () {
                setState(() => _onlyFavorites = !_onlyFavorites);
                _scrollTo(560);
                if (_onlyFavorites && favorites.isEmpty) {
                  _showSnack('В избранном пока пусто — нажмите на сердечко у любой работы');
                }
              }),
            ],
          ),
        ),
        Positioned(
          left: 10,
          top: 380,
          width: 180,
          height: 90,
          child: Column(
            children: <Widget>[
              _infoItem(Icons.info_outline_rounded, 'О нас', () => _showInfoDialog('О нас', 'Hikari · 光 — каталог японских обоев и тем интерфейса.')),
              _infoItem(Icons.description, 'Блог', () => _showInfoDialog('Блог', 'Заметки о японской эстетике, цвете и цифровых обоях.')),
              _infoItem(Icons.help_outline_rounded, 'Помощь', () => _showInfoDialog('Помощь', 'Выберите работу, посмотрите палитру и разрешения, затем примените обои.')),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 510,
          width: 185,
          height: 260,
          child: Image.asset('assets/design/decor-blossom.png', fit: BoxFit.cover),
        ),
        Positioned(
          left: 0,
          top: 760,
          width: 185,
          height: 100,
          child: Image.asset('assets/design/decor-mountains.png', fit: BoxFit.cover),
        ),
        Positioned(
          left: 45,
          top: 820,
          width: 40,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              for (final c in kSideKanji)
                Text(c, style: AppText.kanji(13, color: _muted)),
            ],
          ),
        ),
        Positioned(
          left: 48,
          top: 1150,
          width: 34,
          height: 34,
          child: Container(
            color: AppColors.vermilion,
            child: Center(
              child: Text('光', style: AppText.kanji(18, color: AppColors.paper)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideNavItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          setState(() {});
          onTap();
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF7E9E4) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: active ? _accent : Colors.transparent,
                width: 3,
              ),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 17, color: active ? _accent : _muted),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppText.body(
                  12,
                  color: active ? _ink : _muted,
                  weight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 30,
          child: Row(
            children: <Widget>[
              Icon(icon, size: 15, color: _muted),
              const SizedBox(width: 12),
              Text(label, style: AppText.body(11, color: _muted)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Верхняя панель
  // ---------------------------------------------------------------------------

  Widget _topbar() {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 2,
          top: 2,
          width: 410,
          height: 40,
          child: _searchField(),
        ),
        Positioned(
          left: 572,
          top: 2,
          width: 230,
          height: 40,
          child: _tabsPill(),
        ),
        Positioned(
          left: 852,
          top: 4,
          width: 36,
          height: 36,
          child: Tooltip(
            message: 'Светлая / тёмная тема',
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.wb_sunny_outlined, size: 19, color: AppColors.gold),
              onPressed: _toggleTheme,
            ),
          ),
        ),
        Positioned(
          left: 887,
          top: 8,
          width: 28,
          height: 28,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _showAccentMenu,
              child: Container(
                decoration: BoxDecoration(color: _circleColor, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
        Positioned(
          left: 932,
          top: 2,
          width: 55,
          height: 40,
          child: _languageMenu(),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7DFD3)),
      ),
      child: TextField(
        controller: _search,
        onChanged: (value) {
          setState(() => _query = value);
          _scrollTo(560);
        },
        style: AppText.body(12, color: _ink),
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded, size: 17, color: _muted),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          hintText: 'Поиск обоев, тем, тегов...',
          hintStyle: AppText.body(12, color: _muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _tabsPill() {
    final labels = <String>['Обзор', 'Темы', 'Авторы', 'Теги'];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DFD3)),
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    switch (i) {
                      case 0:
                        _scrollTo(0);
                        break;
                      case 1:
                        _showThemeDialog();
                        break;
                      case 2:
                        _showAuthorsDialog();
                        break;
                      case 3:
                        _showTagsDialog();
                        break;
                    }
                  },
                  child: Center(
                    child: Text(
                      labels[i],
                      style: AppText.body(10.5, color: _muted),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _languageMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() => _language = value);
        _showSnack('Язык интерфейса: $value');
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'RU', child: Text('RU')),
        const PopupMenuItem<String>(value: 'EN', child: Text('EN')),
        const PopupMenuItem<String>(value: 'JA', child: Text('JA')),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_language, style: AppText.label(11, color: _ink)),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _muted),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------------

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/design/hero-clean.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    const Color(0xB3120E0C),
                    const Color(0x00120E0C),
                  ],
                  stops: const <double>[0.0, 0.58],
                ),
              ),
            ),
          ),
          Positioned(
            left: 45,
            top: 24,
            child: Text(
              'Hikari · 光',
              style: AppText.display(20, color: _heroText, weight: FontWeight.w500),
            ),
          ),
          Positioned(
            left: 45,
            top: 60,
            width: 390,
            height: 92,
            child: Text(
              'Красота\nв простых вещах',
              style: AppText.display(44, color: Colors.white, height: 1.04),
            ),
          ),
          Positioned(
            left: 45,
            top: 158,
            width: 390,
            height: 40,
            child: Text(
              'Японские обои и темы, которые наполняют\nваш день атмосферой гармонии.',
              style: AppText.body(12, color: _heroText, height: 1.35),
            ),
          ),
          Positioned(
            left: 45,
            top: 207,
            width: 196,
            height: 40,
            child: FilledButton(
              onPressed: () => _scrollTo(345),
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: const StadiumBorder(),
                textStyle: AppText.label(12, color: Colors.white, letterSpacing: 0.04),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Text('Открыть коллекции'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 15),
                ],
              ),
            ),
          ),
          Positioned(
            right: 32,
            top: 22,
            width: 54,
            height: 205,
            child: _heroKanji(),
          ),
        ],
      ),
    );
  }

  Widget _heroKanji() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          kHeroKanji,
          textAlign: TextAlign.center,
          style: AppText.kanji(14, color: _heroText, height: 1.25),
        ),
        const SizedBox(height: 10),
        Container(width: 1, height: 44, color: Colors.white54),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Обзор и коллекции
  // ---------------------------------------------------------------------------

  Widget _overviewHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('Обзор', style: AppText.display(26, color: _ink)),
        const Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              setState(() {
                _collection = null;
                _filter = 'Все';
                _onlyFavorites = false;
              });
              _scrollTo(560);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Смотреть все', style: AppText.body(11, color: _accent, weight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: _accent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _collectionsRow() {
    return Row(
      children: <Widget>[
        for (var i = 0; i < kDesignCollections.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: _collectionCard(kDesignCollections[i])),
        ],
      ],
    );
  }

  Widget _collectionCard(DesignCollection collection) {
    final active = _collection == collection.id;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _collection = collection.id;
            _filter = 'Все';
            _onlyFavorites = false;
            _query = '';
            _search.clear();
          });
          _scrollTo(560);
        },
        child: Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: _accent, width: 1) : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  collection.image,
                  width: double.infinity,
                  height: 105,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            collection.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.display(17, color: _ink),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${collection.count} обоев',
                            style: AppText.body(10, color: _muted),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: _muted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Каталог
  // ---------------------------------------------------------------------------

  Widget _sortButton() {
    return PopupMenuButton<CatalogSort>(
      onSelected: (value) => setState(() => _sort = value),
      itemBuilder: (context) => <PopupMenuEntry<CatalogSort>>[
        for (final sort in CatalogSort.values)
          PopupMenuItem<CatalogSort>(value: sort, child: Text(_sortLabel(sort))),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            'Сортировка: ${_sortLabel(_sort)}',
            style: AppText.body(10, color: _muted),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _muted),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < kDesignFilters.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          SizedBox(width: _filterW[i], child: _filterChip(kDesignFilters[i])),
        ],
      ],
    );
  }

  Widget _filterChip(String label) {
    final active = _filter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _filter = label;
            _collection = null;
            _onlyFavorites = false;
          });
          _scrollTo(560);
        },
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: active ? _accent : _chip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                9,
                color: active ? Colors.white : _muted,
                weight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _grid(List<DesignItem> visible, Set<String> favorites) {
    if (visible.isEmpty) {
      return Center(
        child: Text(
          'Ничего не найдено — попробуйте другой запрос или фильтр',
          textAlign: TextAlign.center,
          style: AppText.body(12, color: _muted),
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 173 / 128,
      ),
      itemBuilder: (context, index) => _workCard(visible[index], favorites),
    );
  }

  Widget _workCard(DesignItem item, Set<String> favorites) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = item.index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    item.image,
                    width: double.infinity,
                    height: 99,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: _heart(item.catalogId, item.title, favorites),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(12, color: _ink, weight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              '3840 × 2160',
              style: AppText.body(9, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Правая панель детали
  // ---------------------------------------------------------------------------

  Widget _detailPanel(DesignItem item, Set<String> favorites) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 7,
            top: 3,
            width: 229,
            height: 211,
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item.detailImage ?? item.image,
                    width: 229,
                    height: 211,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: _heart(item.catalogId, item.title, favorites, circle: true),
                ),
              ],
            ),
          ),
          Positioned(
            left: 7,
            top: 222,
            width: 229,
            height: 26,
            child: Text(item.title, style: AppText.display(19, color: _ink)),
          ),
          Positioned(
            left: 7,
            top: 250,
            width: 229,
            height: 24,
            child: _tagRow(item.detailTags),
          ),
          Positioned(
            left: 7,
            top: 280,
            width: 229,
            height: 86,
            child: Text(
              item.description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(11, color: _body, height: 1.35),
            ),
          ),
          Positioned(
            left: 7,
            top: 372,
            width: 229,
            height: 20,
            child: Text('Палитра', style: AppText.display(15, color: _ink)),
          ),
          Positioned(
            left: 7,
            top: 392,
            width: 229,
            height: 26,
            child: Row(
              children: <Widget>[
                for (final color in item.palette) _paletteDot(color),
              ],
            ),
          ),
          Positioned(
            left: 7,
            top: 438,
            width: 229,
            height: 20,
            child: Text('Доступные разрешения', style: AppText.display(15, color: _ink)),
          ),
          Positioned(
            left: 7,
            top: 458,
            width: 229,
            height: 70,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (var i = 0; i < kDesignResolutions.length; i++)
                  SizedBox(width: 105, child: _resolutionChip(i)),
              ],
            ),
          ),
          Positioned(
            left: 7,
            top: 520,
            width: 229,
            height: 34,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: () => _applyWallpaper(item),
                    style: FilledButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 34),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: AppText.label(11, color: Colors.white, letterSpacing: 0.02),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Icon(Icons.download_rounded, size: 15),
                        SizedBox(width: 6),
                        Text('Применить обои'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'details') {
                      context.push('/item/${item.catalogId}');
                    } else {
                      _showSnack(value == 'download'
                          ? 'Скачивание доступно в нативной версии Hikari'
                          : 'Ссылка скопирована в буфер (демо)');
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: 'details', child: Text('Детали')),
                    const PopupMenuItem<String>(value: 'download', child: Text('Скачать')),
                    const PopupMenuItem<String>(value: 'share', child: Text('Поделиться')),
                  ],
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      border: Border.all(color: _chip),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.more_vert_rounded, size: 18, color: _muted),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 7,
            top: 580,
            width: 229,
            height: 20,
            child: Text('Похожие обои', style: AppText.display(15, color: _ink)),
          ),
          Positioned(
            left: 7,
            top: 602,
            width: 229,
            height: 52,
            child: _similarThumbs(item),
          ),
        ],
      ),
    );
  }

  Widget _tagRow(List<String> tags) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < tags.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _tagChip(tags[i]),
          ],
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _chip,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(tag, style: AppText.body(9, color: _muted)),
    );
  }

  Widget _paletteDot(Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _setAccent(color);
            _showSnack('Акцент изменён');
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _resolutionChip(int index) {
    final active = _resolution == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _resolution = index),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFBEFEA) : _chip,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: _accent, width: 1) : null,
          ),
          child: Center(
            child: Text(
              kDesignResolutions[index],
              style: AppText.body(
                9,
                color: active ? _accent : _body,
                weight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _similarThumbs(DesignItem item) {
    final images = item.similarImages;
    return Row(
      children: <Widget>[
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _similarThumb(item, i, images),
        ],
        const Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () => setState(() => _similarOffset += 1),
            child: const Icon(Icons.chevron_right_rounded, size: 20, color: _muted),
          ),
        ),
      ],
    );
  }

  Widget _similarThumb(DesignItem item, int i, List<String>? images) {
    final index = item.similar[(_similarOffset + i) % item.similar.length];
    final similar = kDesignItems[index];
    final asset = images != null && _similarOffset == 0 && i < images.length
        ? images[i]
        : similar.image;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = similar.index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            asset,
            width: 44,
            height: 52,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  Widget _heart(
    String id,
    String label,
    Set<String> favorites, {
    bool circle = false,
  }) {
    final active = favorites.contains(id);
    final icon = Icon(
      active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      size: circle ? 18 : 17,
      color: circle ? (active ? _accent : AppColors.vermilion) : (active ? _accent : Colors.white),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _toggleFavorite(id, label),
        child: circle
            ? Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(child: icon),
              )
            : icon,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Состояние и действия
  // ---------------------------------------------------------------------------

  List<DesignItem> _visibleItems(Set<String> favorites) {
    final query = _query.trim().toLowerCase();
    var list = List<DesignItem>.from(kDesignItems);

    if (_onlyFavorites) {
      list = list.where((item) => favorites.contains(item.catalogId)).toList();
    }
    if (_collection != null) {
      list = list.where((item) => item.collection == _collection).toList();
    }
    if (_filter != 'Все') {
      list = list.where((item) => item.tags.contains(_filter)).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.tags.any((tag) => tag.toLowerCase().contains(query)) ||
            item.detailTags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    switch (_sort) {
      case CatalogSort.popular:
        // В выбранном макете «Популярные» = порядок работ на референсе.
        list.sort((a, b) => a.index.compareTo(b.index));
        break;
      case CatalogSort.newest:
        list.sort((a, b) => a.index.compareTo(b.index));
        break;
      case CatalogSort.alphabetical:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return list;
  }

  void _scrollTo(double designY) {
    if (!_scroll.hasClients) return;
    final target = (designY * _scale)
        .clamp(0.0, _scroll.position.maxScrollExtent)
        .toDouble();
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleFavorite(String id, String label) {
    final was = ref.read(favoritesProvider).contains(id);
    ref.read(favoritesProvider.notifier).toggle(id);
    _showSnack(was ? '$label удалено из избранного' : '$label добавлено в избранное');
  }

  void _setAccent(Color color) {
    setState(() {
      _accent = color;
      _circleColor = color;
    });
  }

  void _applyWallpaper(DesignItem item) {
    ref.read(activeThemeIdProvider.notifier).set(item.catalogId);
    _setAccent(item.palette.first);
    _showSnack('Обои «${item.title}» применены к интерфейсу Hikari');
  }

  void _toggleTheme() {
    final current = ref.read(themeModeProvider);
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(themeModeProvider.notifier).set(next);
    _showSnack(next == ThemeMode.dark
        ? 'Тёмная тема включена для остальных экранов'
        : 'Светлая тема включена');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: AppText.body(12, color: Colors.white))),
    );
  }

  void _showThemeDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Темы интерфейса'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Светлая «васи»'),
              onTap: () {
                ref.read(themeModeProvider.notifier).set(ThemeMode.light);
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.nights_stay_outlined),
              title: const Text('Тёмная «суми»'),
              onTap: () {
                ref.read(themeModeProvider.notifier).set(ThemeMode.dark);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccentMenu() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Акцент'),
        content: SizedBox(
          width: 260,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (final color in kFujiPalette)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      _setAccent(color);
                      Navigator.of(dialogContext).pop();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagsDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Теги'),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final tag in kDesignFilters.skip(1))
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _filter = tag;
                        _collection = null;
                        _onlyFavorites = false;
                      });
                      Navigator.of(dialogContext).pop();
                      _scrollTo(560);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(14)),
                      child: Text(tag, style: AppText.body(11, color: _body)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuthorsDialog() {
    _showInfoDialog('Авторы', 'Коллекция собрана командой Hikari: японская эстетика, сгенерированные изображения и живая вёрстка Flutter Web.');
  }

  void _showInfoDialog(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Понятно'),
          ),
        ],
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
        children: <Widget>[
          KanjiMark(size: 96, color: theme.colorScheme.primary, opacity: 0.18),
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
          children: <Widget>[
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
