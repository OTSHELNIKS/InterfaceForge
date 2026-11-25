import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/core/widgets/hikari_logo.dart';
import 'package:hikari/features/home/design_data.dart';
import 'package:hikari/features/website/download.dart';

const paper = Color(0xFFF2EDE3);
const card = Color(0xFFFAF6EE);
const ink = Color(0xFF241D19);
const muted = Color(0xFF75685F);
const red = Color(0xFFC9362B);
const line = Color(0xFFE4DACE);

Duration motion(BuildContext context) => MediaQuery.disableAnimationsOf(context)
    ? Duration.zero : const Duration(milliseconds: 200);

const _nav = <(String, String, IconData)>[
  ('/home', 'Главная', Icons.home_outlined),
  ('/catalog', 'Каталог', Icons.grid_view_rounded),
  ('/collections', 'Коллекции', Icons.auto_awesome_outlined),
  ('/favorites', 'Избранное', Icons.favorite_border_rounded),
  ('/about', 'О проекте', Icons.info_outline_rounded),
];

class WebsiteShell extends ConsumerStatefulWidget {
  const WebsiteShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;
  @override
  ConsumerState<WebsiteShell> createState() => _WebsiteShellState();
}

class _WebsiteShellState extends ConsumerState<WebsiteShell> {
  late bool _collapsed;
  @override
  void initState() {
    super.initState();
    _collapsed = ref.read(sharedPreferencesProvider).getBool('hikari.sidebarCollapsed') ?? false;
  }

  bool _active(String path) => widget.location == path ||
      (path == '/catalog' && widget.location.startsWith('/item/'));

  void _go(String path, {bool drawer = false}) {
    if (drawer) Navigator.of(context).pop();
    context.go(path);
  }

  Widget _navigation({required bool collapsed, bool drawer = false}) {
    return Container(
      color: paper,
      child: SafeArea(child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(collapsed ? 8 : 20, 18, collapsed ? 8 : 10, 22),
          child: Row(children: <Widget>[
            if (!collapsed) Expanded(child: InkWell(
              onTap: () => _go('/home', drawer: drawer),
              child: const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: HikariLogo(size: 25)),
            )) else const Expanded(child: Text('光', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, color: red))),
            if (!drawer && !collapsed) IconButton(
              tooltip: 'Свернуть меню',
              onPressed: _toggle,
              icon: const Icon(Icons.menu_open_rounded, size: 21, color: muted),
            ),
          ]),
        ),
        if (!drawer && collapsed) IconButton(tooltip: 'Развернуть меню', onPressed: _toggle, icon: const Icon(Icons.menu_rounded, color: muted)),
        for (final entry in _nav)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Tooltip(
              message: collapsed ? entry.$2 : '',
              child: Semantics(
                selected: _active(entry.$1),
                button: true,
                label: collapsed ? entry.$2 : null,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _go(entry.$1, drawer: drawer),
                    child: AnimatedContainer(
                      duration: motion(context),
                      height: 48,
                      decoration: BoxDecoration(
                        color: _active(entry.$1) ? const Color(0xFFF8E4DC) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _active(entry.$1) ? const Color(0xFFE9BFB0) : Colors.transparent),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 14),
                      child: Row(mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start, children: <Widget>[
                        Icon(entry.$3, color: _active(entry.$1) ? red : muted, size: 20),
                        if (!collapsed) ...<Widget>[
                          const SizedBox(width: 12),
                          Flexible(child: Text(entry.$2, overflow: TextOverflow.ellipsis, style: AppText.body(14, color: _active(entry.$1) ? ink : muted, weight: _active(entry.$1) ? FontWeight.w600 : FontWeight.w400))),
                        ],
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        if (!collapsed) Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Image.asset('assets/design/decor-blossom.png', height: 110, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text('ЯПОНСКАЯ ЭСТЕТИКА\nВ КАЖДОЙ ДЕТАЛИ', style: AppText.label(10, color: muted, height: 1.6)),
          ]),
        ),
      ])),
    );
  }

  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    ref.read(sharedPreferencesProvider).setBool('hikari.sidebarCollapsed', _collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: paper,
      drawer: wide ? null : Drawer(child: _navigation(collapsed: false, drawer: true)),
      appBar: wide ? null : AppBar(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        title: const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: HikariLogo(size: 22)),
        actions: <Widget>[
          IconButton(tooltip: 'Каталог', onPressed: () => context.go('/catalog'), icon: const Icon(Icons.search_rounded)),
          IconButton(tooltip: 'Избранное', onPressed: () => context.go('/favorites'), icon: const Icon(Icons.favorite_border_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(children: <Widget>[
        if (wide) AnimatedContainer(
          duration: motion(context),
          curve: Curves.easeOutCubic,
          width: _collapsed ? 76 : 210,
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: line))),
          child: _navigation(collapsed: _collapsed),
        ),
        Expanded(child: widget.child),
      ]),
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: PageStorageKey<String>(GoRouterState.of(context).uri.toString()),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1220),
      child: Padding(
        padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width < 600 ? 16 : 32, 24, MediaQuery.sizeOf(context).width < 600 ? 16 : 32, 56),
        child: child,
      ),
    )),
  );
}

Widget sectionTitle(String title, {String? eyebrow, String? description}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    if (eyebrow != null) ...<Widget>[Text(eyebrow.toUpperCase(), style: AppText.label(10, color: red)), const SizedBox(height: 10)],
    Text(title, style: AppText.display(32, color: ink, height: 1.15)),
    if (description != null) ...<Widget>[const SizedBox(height: 8), Text(description, style: AppText.body(14, color: muted))],
  ],
);

class WebsiteHome extends StatelessWidget {
  const WebsiteHome({super.key});
  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < 600;
    return PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      ClipRRect(borderRadius: BorderRadius.circular(18), child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: small ? 330 : 340),
        child: Stack(children: <Widget>[
          Positioned.fill(child: Image.asset('assets/design/hero-clean.jpg', fit: BoxFit.cover)),
          const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: <Color>[Color(0xE51A1A21), Color(0x661A1A21), Color(0x111A1A21)])))),
          Padding(padding: EdgeInsets.all(small ? 24 : 44), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('HIKARI · 光', style: AppText.label(12, color: Colors.white70)),
            const SizedBox(height: 14),
            Text('Красота\nв простых вещах', style: AppText.display(small ? 30 : 42, color: Colors.white, height: 1.12)),
            const SizedBox(height: 12),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Text('Японские мотивы, спокойные цвета и маленькие моменты гармонии.', style: AppText.body(14, color: Colors.white, height: 1.4))),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: () => context.go('/collections'), style: FilledButton.styleFrom(backgroundColor: red, foregroundColor: Colors.white, minimumSize: const Size(0, 48)), icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: const Text('Открыть коллекции')),
          ])),
        ]),
      )),
      const SizedBox(height: 38),
      Row(children: <Widget>[
        Expanded(child: sectionTitle('Коллекции', eyebrow: 'Откройте для себя')),
        TextButton(onPressed: () => context.go('/collections'), child: const Text('Все коллекции →')),
      ]),
      const SizedBox(height: 18),
      const CollectionGrid(),
      const SizedBox(height: 42),
      Row(children: <Widget>[
        Expanded(child: sectionTitle('Избранные работы', eyebrow: 'Каталог')),
        TextButton(onPressed: () => context.go('/catalog'), child: const Text('Весь каталог →')),
      ]),
      const SizedBox(height: 18),
      WorkGrid(items: kDesignItems.take(8).toList()),
      const SizedBox(height: 30),
      const _Notice(),
    ]));
  }
}

class _Notice extends StatelessWidget {
  const _Notice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF8EDE4), borderRadius: BorderRadius.circular(12)),
    child: Text('Сейчас доступны небольшие изображения из дизайн-концепции. Полноразмерные обои для этих работ ещё не подготовлены.', style: AppText.body(13, color: muted)),
  );
}

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final cols = c.maxWidth >= 820 ? 4 : c.maxWidth >= 480 ? 2 : 1;
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: kDesignCollections.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 14, mainAxisSpacing: 14, mainAxisExtent: 210),
      itemBuilder: (context, index) {
        final collection = kDesignCollections[index];
        final count = kDesignItems.where((x) => x.collection == collection.id).length;
        return Material(color: card, borderRadius: BorderRadius.circular(14), clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: () => context.go('/catalog?collection=${collection.id}'), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(child: Image.asset(collection.image, width: double.infinity, fit: BoxFit.cover)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: <Widget>[
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(collection.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.display(17, color: ink)),
                const SizedBox(height: 4), Text('$count ${workCount(count)}', style: AppText.body(12, color: muted)),
              ])),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: red),
            ])),
          ])),
        );
      },
    );
  });
}

String workCount(int n) => n % 10 == 1 && n % 100 != 11 ? 'работа' : n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20) ? 'работы' : 'работ';

class WebsiteCollections extends StatelessWidget {
  const WebsiteCollections({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    sectionTitle('Коллекции', eyebrow: 'Hikari · 光', description: 'Четыре настроения японской эстетики. Выберите подборку, чтобы увидеть её работы.'),
    const SizedBox(height: 26), const CollectionGrid(),
  ]));
}

class WebsiteCatalog extends ConsumerStatefulWidget {
  const WebsiteCatalog({super.key, this.uri, this.favoritesOnly = false});
  final Uri? uri;
  final bool favoritesOnly;
  @override
  ConsumerState<WebsiteCatalog> createState() => _WebsiteCatalogState();
}

class _WebsiteCatalogState extends ConsumerState<WebsiteCatalog> {
  late final TextEditingController _search;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.uri?.queryParameters['q'] ?? '');
  }
  @override
  void didUpdateWidget(covariant WebsiteCatalog oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldQ = oldWidget.uri?.queryParameters['q'] ?? '';
    final newQ = widget.uri?.queryParameters['q'] ?? '';
    if (oldQ != newQ && _search.text != newQ) {
      _search.value = TextEditingValue(text: newQ, selection: TextSelection.collapsed(offset: newQ.length));
    }
  }
  @override
  void dispose() { _debounce?.cancel(); _search.dispose(); super.dispose(); }

  void _setQuery(String key, String? value) {
    final params = Map<String, String>.from(widget.uri?.queryParameters ?? <String, String>{});
    if (value == null || value.isEmpty) { params.remove(key); } else { params[key] = value; }
    context.go(Uri(path: widget.favoritesOnly ? '/favorites' : '/catalog', queryParameters: params.isEmpty ? null : params).toString());
  }

  @override
  Widget build(BuildContext context) {
    final params = widget.uri?.queryParameters ?? <String, String>{};
    final collection = int.tryParse(params['collection'] ?? '');
    final filter = params['tag'] ?? 'Все';
    final query = (params['q'] ?? '').trim().toLowerCase();
    final sort = params['sort'] ?? 'reference';
    final favorites = ref.watch(favoritesProvider);
    final items = kDesignItems.where((item) =>
      (!widget.favoritesOnly || favorites.contains(item.catalogId)) &&
      (collection == null || item.collection == collection) &&
      (filter == 'Все' || item.tags.contains(filter)) &&
      (query.isEmpty || item.title.toLowerCase().contains(query) || item.description.toLowerCase().contains(query) || item.tags.any((t) => t.toLowerCase().contains(query)) || item.detailTags.any((t) => t.toLowerCase().contains(query)))
    ).toList();
    if (sort == 'popular') items.sort((a, b) => b.popularity.compareTo(a.popularity));
    if (sort == 'name') items.sort((a, b) => a.title.compareTo(b.title));
    final title = widget.favoritesOnly ? 'Избранное' : collection != null && collection >= 0 && collection < kDesignCollections.length ? kDesignCollections[collection].title : 'Каталог';
    return PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      sectionTitle(title, eyebrow: 'Hikari · 光', description: '${items.length} ${workCount(items.length)}${widget.favoritesOnly ? ' · сохранено в этом браузере' : ' · японская эстетика'}'),
      const SizedBox(height: 24),
      if (!widget.favoritesOnly) ...<Widget>[
        TextField(
          controller: _search,
          onChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 250), () { if (mounted) _setQuery('q', value.trim()); });
          },
          onSubmitted: (value) { _debounce?.cancel(); _setQuery('q', value.trim()); },
          decoration: InputDecoration(
            labelText: 'Поиск по названию и тегам',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(tooltip: 'Очистить поиск', onPressed: () { _search.clear(); _debounce?.cancel(); _setQuery('q', null); }, icon: const Icon(Icons.close_rounded)),
            filled: true, fillColor: card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
          for (final tag in kDesignFilters)
            ChoiceChip(
              label: Text(tag), selected: tag == filter,
              showCheckmark: true, selectedColor: const Color(0xFFF4DCD3),
              onSelected: (_) => _setQuery('tag', tag == 'Все' ? null : tag),
            ),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
          if (collection != null) InputChip(label: Text('Коллекция: $title'), onDeleted: () => _setQuery('collection', null)),
          PopupMenuButton<String>(
            tooltip: 'Сортировка',
            onSelected: (value) => _setQuery('sort', value == 'reference' ? null : value),
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem(value: 'reference', child: Text('Рекомендуемые')),
              PopupMenuItem(value: 'popular', child: Text('Популярные')),
              PopupMenuItem(value: 'name', child: Text('По алфавиту')),
            ],
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text('Сортировка: ${sort == 'popular' ? 'Популярные' : sort == 'name' ? 'По алфавиту' : 'Рекомендуемые'}', style: AppText.body(13, color: muted)),
              const Icon(Icons.keyboard_arrow_down_rounded, color: muted),
            ])),
          ),
          if (params.isNotEmpty) TextButton(onPressed: () { _search.clear(); context.go('/catalog'); }, child: const Text('Сбросить фильтры')),
        ]),
        const SizedBox(height: 16),
      ] else const SizedBox(height: 18),
      if (items.isEmpty) Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
        child: Column(children: <Widget>[
          const Icon(Icons.search_off_rounded, color: muted, size: 38),
          const SizedBox(height: 12),
          Text(widget.favoritesOnly ? 'Здесь пока ничего нет' : 'Ничего не найдено', style: AppText.display(22, color: ink)),
          const SizedBox(height: 8),
          Text(widget.favoritesOnly ? 'Сохраняйте понравившиеся работы сердечком.' : 'Попробуйте изменить запрос или фильтры.', textAlign: TextAlign.center, style: AppText.body(14, color: muted)),
          const SizedBox(height: 12),
          TextButton(onPressed: () => context.go('/catalog'), child: Text(widget.favoritesOnly ? 'Открыть каталог' : 'Сбросить фильтры')),
        ]),
      ) else WorkGrid(items: items),
      const SizedBox(height: 30), const _Notice(),
    ]));
  }
}

class WorkGrid extends StatelessWidget {
  const WorkGrid({super.key, required this.items});
  final List<DesignItem> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth;
    final cols = width >= 850 ? 4 : width >= 580 ? 3 : width >= 310 ? 2 : 1;
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 14, mainAxisSpacing: 20, mainAxisExtent: ((width - (cols - 1) * 14) / cols) * .64 + 60),
      itemBuilder: (context, index) => WorkCard(item: items[index]),
    );
  });
}

class WorkCard extends ConsumerStatefulWidget {
  const WorkCard({super.key, required this.item});
  final DesignItem item;
  @override
  ConsumerState<WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends ConsumerState<WorkCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final favorite = ref.watch(favoritesProvider).contains(item.catalogId);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true), onExit: (_) => setState(() => _hover = false),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(child: Stack(fit: StackFit.expand, children: <Widget>[
          AnimatedScale(
            scale: _hover && !MediaQuery.disableAnimationsOf(context) ? 0.98 : 1,
            duration: motion(context), curve: Curves.easeOut,
            child: Material(color: card, borderRadius: BorderRadius.circular(12), clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: ValueKey<String>('work-${item.catalogId}'),
                onTap: () => context.go('/item/${item.catalogId}'),
                child: Semantics(label: 'Открыть ${item.title}', button: true, child: Ink.image(image: AssetImage(item.image), fit: BoxFit.cover)),
              ),
            ),
          ),
          Positioned(right: 4, top: 4, child: FavoriteButton(item: item, favorite: favorite)),
        ])),
        const SizedBox(height: 8),
        Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(14, color: ink, weight: FontWeight.w600)),
        Text('Превью', style: AppText.body(11, color: muted)),
      ]),
    );
  }
}

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.item, required this.favorite});
  final DesignItem item;
  final bool favorite;
  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton.filled(
    tooltip: favorite ? 'Удалить из избранного' : 'Добавить в избранное',
    onPressed: () => ref.read(favoritesProvider.notifier).toggle(item.catalogId),
    style: IconButton.styleFrom(backgroundColor: favorite ? red : const Color(0xB0231C18), foregroundColor: Colors.white),
    icon: AnimatedSwitcher(duration: motion(context), child: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, key: ValueKey<bool>(favorite), size: 20)),
  );
}

class WebsiteDetail extends ConsumerWidget {
  const WebsiteDetail({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = kDesignItems.where((i) => i.catalogId == id);
    if (matches.isEmpty) return PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      sectionTitle('Работа не найдена'), const SizedBox(height: 16),
      TextButton(onPressed: () => context.go('/catalog'), child: const Text('Вернуться в каталог')),
    ]));
    final item = matches.first;
    final favorite = ref.watch(favoritesProvider).contains(item.catalogId);
    final imageWidth = <int>[173, 170, 172, 175][item.index % 4];
    final imageHeight = item.index < 4 ? 99 : 100;
    return PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      TextButton.icon(onPressed: () => context.go('/catalog'), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Каталог')),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final image = ClipRRect(borderRadius: BorderRadius.circular(16), child: AspectRatio(aspectRatio: 1.65, child: Image.asset(item.image, fit: BoxFit.cover, filterQuality: FilterQuality.high)));
        final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('КОЛЛЕКЦИЯ · ${kDesignCollections[item.collection].title.toUpperCase()}', style: AppText.label(10, color: red)),
          const SizedBox(height: 12),
          Text(item.title, style: AppText.display(32, color: ink, height: 1.15)),
          const SizedBox(height: 14),
          Wrap(spacing: 7, runSpacing: 7, children: <Widget>[for (final tag in item.detailTags) Chip(label: Text(tag), backgroundColor: card, side: BorderSide.none)]),
          const SizedBox(height: 12),
          Text(item.description, style: AppText.body(15, color: muted, height: 1.55)),
          const SizedBox(height: 22),
          Text('Палитра', style: AppText.display(19, color: ink)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: <Widget>[for (final color in item.palette) Container(width: 32, height: 32, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: line)))]),
          const SizedBox(height: 22),
          Text('Доступный файл', style: AppText.display(19, color: ink)),
          const SizedBox(height: 8),
          Text('Превью JPEG · $imageWidth × $imageHeight пикселей', style: AppText.body(14, color: ink)),
          const SizedBox(height: 6),
          Text('Это изображение из дизайн-концепции, а не полноразмерные обои. Версии 4K и для телефона пока недоступны.', style: AppText.body(13, color: muted)),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: <Widget>[
            FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await downloadPreview(item.image, 'hikari-${item.catalogId}-preview.jpg');
                messenger.showSnackBar(SnackBar(content: Text(ok ? 'Скачивание превью началось' : 'Скачивание доступно в веб-версии')));
              },
              style: FilledButton.styleFrom(backgroundColor: red, foregroundColor: Colors.white, minimumSize: const Size(0, 48)),
              icon: const Icon(Icons.download_rounded), label: const Text('Скачать превью'),
            ),
            FavoriteButton(item: item, favorite: favorite),
          ]),
        ]);
        if (!wide) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[image, const SizedBox(height: 24), info]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Expanded(flex: 6, child: image), const SizedBox(width: 32), Expanded(flex: 4, child: info),
        ]);
      }),
      const SizedBox(height: 42),
      sectionTitle('Похожие работы', eyebrow: 'Продолжить просмотр'),
      const SizedBox(height: 18),
      WorkGrid(items: item.similar.map((i) => kDesignItems[i]).toList()),
    ]));
  }
}

class WebsiteAbout extends StatelessWidget {
  const WebsiteAbout({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
    sectionTitle('О проекте', eyebrow: 'Hikari · 光', description: 'Небольшая коллекция японских мотивов и спокойных визуальных историй.'),
    const SizedBox(height: 26),
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('О коллекции', style: AppText.display(22, color: ink)),
        const SizedBox(height: 10),
        Text('В каталоге представлены изображения, извлечённые из созданной для проекта дизайн-концепции. Сейчас это небольшие превью, а не файлы обоев высокого разрешения.', style: AppText.body(15, color: muted)),
        const SizedBox(height: 22),
        Text('Использование', style: AppText.display(22, color: ink)),
        const SizedBox(height: 10),
        Text('Условия повторного и коммерческого использования изображений пока не опубликованы. Не полагайтесь на право коммерческого использования до их уточнения.', style: AppText.body(15, color: muted)),
        const SizedBox(height: 22),
        Text('Избранное', style: AppText.display(22, color: ink)),
        const SizedBox(height: 10),
        Text('Избранное и состояние бокового меню сохраняются в текущем браузере. При очистке данных браузера они могут быть удалены.', style: AppText.body(15, color: muted)),
        const SizedBox(height: 14),
        TextButton(onPressed: () => context.go('/catalog'), child: const Text('Перейти в каталог →')),
      ]),
    ),
  ]));
}
