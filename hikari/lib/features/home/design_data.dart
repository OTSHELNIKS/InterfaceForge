import 'package:material_ui/material_ui.dart';

/// Графические элементы и контент, извлечённые из выбранного светлого макета.
/// Это данные для настоящих виджетов, а не целый скриншот-подложка.
class DesignCollection {
  const DesignCollection({
    required this.id,
    required this.title,
    required this.count,
    required this.image,
  });

  final int id;
  final String title;
  final int count;
  final String image;
}

class DesignItem {
  const DesignItem({
    required this.index,
    required this.title,
    required this.catalogId,
    required this.image,
    required this.collection,
    required this.tags,
    required this.detailTags,
    required this.description,
    required this.palette,
    required this.popularity,
    required this.similar,
    this.detailImage,
    this.similarImages,
  });

  final int index;
  final String title;
  final String catalogId;
  final String image;
  final int collection;
  final List<String> tags;
  final List<String> detailTags;
  final String description;
  final List<Color> palette;
  final int popularity;
  final List<int> similar;
  final String? detailImage;
  final List<String>? similarImages;
}

const Color _vermilion = Color(0xFFC9362B);
const Color _peach = Color(0xFFF3A98F);
const Color _cream = Color(0xFFE8DBCE);
const Color _slate = Color(0xFF7B8FA8);
const Color _navy = Color(0xFF16232F);
const Color _gold = Color(0xFFC9A227);
const Color _sakura = Color(0xFFEBA6B7);
const Color _indigo = Color(0xFF2E4A73);
const Color _moss = Color(0xFF4F6B4A);
const Color _ink = Color(0xFF1E1917);

const List<Color> kFujiPalette = <Color>[
  _vermilion,
  _peach,
  _cream,
  _slate,
  _navy,
  _gold,
];
const List<Color> kAutumnPalette = <Color>[
  _vermilion,
  Color(0xFFE76A3A),
  Color(0xFFF1C27D),
  Color(0xFF8B5A3C),
  _ink,
  _gold,
];
const List<Color> kCityPalette = <Color>[
  Color(0xFF7B4AA8),
  _sakura,
  Color(0xFF4B6FA8),
  Color(0xFF24334F),
  _ink,
  _vermilion,
];
const List<Color> kWinterPalette = <Color>[
  Color(0xFFB9C7D6),
  Color(0xFFE5EEF5),
  _cream,
  _slate,
  _navy,
  _gold,
];
const List<Color> kArtPalette = <Color>[
  _indigo,
  Color(0xFF6E93B8),
  _cream,
  Color(0xFF9A7A52),
  _ink,
  _vermilion,
];
const List<Color> kGreenPalette = <Color>[
  _moss,
  Color(0xFF9AB46B),
  Color(0xFFE2D9A8),
  Color(0xFF6E7F58),
  _ink,
  _gold,
];

const List<String> kDesignFilters = <String>[
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

const List<String> kDesignResolutions = <String>[
  '3840 × 2160',
  '2560 × 1440',
  '1920 × 1080',
  'Mobile (1080 × 1920)',
];

const List<DesignCollection> kDesignCollections = <DesignCollection>[
  DesignCollection(
    id: 0,
    title: 'Сезоны Японии',
    count: 64,
    image: 'assets/design/collection-1.jpg',
  ),
  DesignCollection(
    id: 1,
    title: 'Города и улицы',
    count: 48,
    image: 'assets/design/collection-2.jpg',
  ),
  DesignCollection(
    id: 2,
    title: 'Интерьеры',
    count: 36,
    image: 'assets/design/collection-3.jpg',
  ),
  DesignCollection(
    id: 3,
    title: 'Классика и искусство',
    count: 52,
    image: 'assets/design/collection-4.jpg',
  ),
];

const List<DesignItem> kDesignItems = <DesignItem>[
  DesignItem(
    index: 0,
    title: 'Утро в Киото',
    catalogId: 'akane-no-sora',
    image: 'assets/design/work-01.jpg',
    collection: 0,
    tags: <String>['Природа', 'Города', 'Лето'],
    detailTags: <String>['Природа', 'Города', 'Утро', 'Япония'],
    description:
        'Мягкий свет над старой улицей Киото: деревянные фасады, камень и первые лучи солнца.',
    palette: kAutumnPalette,
    popularity: 92,
    similar: <int>[3, 5, 15, 1],
  ),
  DesignItem(
    index: 1,
    title: 'Красные клёны',
    catalogId: 'vermilion-dusk',
    image: 'assets/design/work-02.jpg',
    collection: 0,
    tags: <String>['Природа', 'Искусство', 'Лето'],
    detailTags: <String>['Природа', 'Осень', 'Клёны', 'Япония'],
    description:
        'Алые клёны обрамляют тихий храм; насыщенный осенний контраст и тёплая дымка.',
    palette: kAutumnPalette,
    popularity: 88,
    similar: <int>[15, 0, 9, 3],
  ),
  DesignItem(
    index: 2,
    title: 'Тихий храм',
    catalogId: 'kintoki',
    image: 'assets/design/work-03.jpg',
    collection: 2,
    tags: <String>['Зима', 'Минимализм', 'Интерьеры'],
    detailTags: <String>['Зима', 'Храм', 'Тишина', 'Япония'],
    description:
        'Зимний храм среди заснеженных деревьев, приглушённые синие тени и спокойная тишина.',
    palette: kWinterPalette,
    popularity: 76,
    similar: <int>[7, 13, 14, 3],
  ),
  DesignItem(
    index: 3,
    title: 'Фудзи на рассвете',
    catalogId: 'hinomaru',
    image: 'assets/design/work-04.jpg',
    detailImage: 'assets/design/detail-fuji.jpg',
    collection: 0,
    tags: <String>['Природа', 'Минимализм', 'Лето'],
    detailTags: <String>['Природа', 'Горы', 'Рассвет', 'Япония'],
    description:
        'Первые лучи солнца озаряют вершину Фудзи, отражаясь в спокойных водах озера. Момент тишины, в котором рождается новый день.',
    palette: kFujiPalette,
    popularity: 98,
    similar: <int>[0, 5, 8, 10],
    similarImages: <String>[
      'assets/design/similar-1.jpg',
      'assets/design/similar-2.jpg',
      'assets/design/similar-3.jpg',
      'assets/design/similar-4.jpg',
    ],
  ),
  DesignItem(
    index: 4,
    title: 'Улицы Токио',
    catalogId: 'yozakura',
    image: 'assets/design/work-05.jpg',
    collection: 1,
    tags: <String>['Города', 'Ночь', 'Аниме'],
    detailTags: <String>['Города', 'Ночь', 'Неон', 'Токио'],
    description:
        'Неоновые вывески и влажный асфальт: ночной город в отражениях фиолетового и алого.',
    palette: kCityPalette,
    popularity: 95,
    similar: <int>[11, 6, 1, 10],
  ),
  DesignItem(
    index: 5,
    title: 'Весеннее отражение',
    catalogId: 'somei-yoshino',
    image: 'assets/design/work-06.jpg',
    collection: 0,
    tags: <String>['Природа', 'Лето', 'Искусство'],
    detailTags: <String>['Природа', 'Весна', 'Сакура', 'Япония'],
    description:
        'Сакура над водой и пагода вдалеке; нежная розовая дымка весеннего утра.',
    palette: kAutumnPalette,
    popularity: 84,
    similar: <int>[0, 3, 12, 1],
  ),
  DesignItem(
    index: 6,
    title: 'Путь фонарей',
    catalogId: 'hanafubuki',
    image: 'assets/design/work-07.jpg',
    collection: 1,
    tags: <String>['Города', 'Ночь', 'Интерьеры'],
    detailTags: <String>['Города', 'Вечер', 'Фонари', 'Япония'],
    description:
        'Тёплые фонари вдоль старой улицы, глубокие тени и мягкий вечерний свет.',
    palette: kCityPalette,
    popularity: 79,
    similar: <int>[4, 11, 7, 2],
  ),
  DesignItem(
    index: 7,
    title: 'Зимняя тишина',
    catalogId: 'sakura-no-uta',
    image: 'assets/design/work-08.jpg',
    collection: 2,
    tags: <String>['Зима', 'Минимализм', 'Интерьеры'],
    detailTags: <String>['Зима', 'Тишина', 'Свет', 'Япония'],
    description:
        'Заснеженная хижина у леса, синие сумерки и тихое свечение окон.',
    palette: kWinterPalette,
    popularity: 73,
    similar: <int>[13, 2, 8, 14],
  ),
  DesignItem(
    index: 8,
    title: 'Одинокое дерево',
    catalogId: 'sumi-no-mai',
    image: 'assets/design/work-09.jpg',
    collection: 3,
    tags: <String>['Природа', 'Минимализм', 'Искусство'],
    detailTags: <String>['Природа', 'Минимализм', 'Дерево', 'Япония'],
    description:
        'Одинокое дерево на каменистом склоне под высоким небом — минимализм и простор.',
    palette: kArtPalette,
    popularity: 68,
    similar: <int>[9, 3, 14, 10],
  ),
  DesignItem(
    index: 9,
    title: 'Золотой вечер',
    catalogId: 'kurogane',
    image: 'assets/design/work-10.jpg',
    collection: 0,
    tags: <String>['Природа', 'Лето', 'Искусство'],
    detailTags: <String>['Природа', 'Закат', 'Золото', 'Япония'],
    description:
        'Солнце за силуэтом сосны, золотой горизонт и длинные вечерние тени.',
    palette: kAutumnPalette,
    popularity: 86,
    similar: <int>[1, 0, 12, 15],
  ),
  DesignItem(
    index: 10,
    title: 'Волны',
    catalogId: 'ink-and-gold',
    image: 'assets/design/work-11.jpg',
    collection: 3,
    tags: <String>['Искусство', 'Минимализм', 'Аниме'],
    detailTags: <String>['Искусство', 'Волны', 'Индиго', 'Классика'],
    description:
        'Классическая волна в индиго и белой пене, графичный ритм японской гравюры.',
    palette: kArtPalette,
    popularity: 91,
    similar: <int>[3, 14, 8, 5],
  ),
  DesignItem(
    index: 11,
    title: 'Ночной Токио',
    catalogId: 'kannon',
    image: 'assets/design/work-12.jpg',
    collection: 1,
    tags: <String>['Города', 'Ночь', 'Аниме'],
    detailTags: <String>['Города', 'Ночь', 'Неон', 'Токио'],
    description:
        'Ночные небоскрёбы, неон и вертикальный ритм мегаполиса.',
    palette: kCityPalette,
    popularity: 89,
    similar: <int>[4, 6, 1, 10],
  ),
  DesignItem(
    index: 12,
    title: 'Поле цветов',
    catalogId: 'ai-no-kawa',
    image: 'assets/design/work-13.jpg',
    collection: 0,
    tags: <String>['Природа', 'Лето', 'Искусство'],
    detailTags: <String>['Природа', 'Поле', 'Утро', 'Япония'],
    description:
        'Цветущее поле у подножия гор, мягкое утро и прозрачный воздух.',
    palette: kGreenPalette,
    popularity: 70,
    similar: <int>[5, 0, 9, 15],
  ),
  DesignItem(
    index: 13,
    title: 'Снежный храм',
    catalogId: 'ruri',
    image: 'assets/design/work-14.jpg',
    collection: 2,
    tags: <String>['Зима', 'Минимализм', 'Интерьеры'],
    detailTags: <String>['Зима', 'Храм', 'Тушь', 'Япония'],
    description:
        'Пагода среди зимнего леса, тушь и снег, почти монохромная тишина.',
    palette: kWinterPalette,
    popularity: 72,
    similar: <int>[2, 7, 14, 8],
  ),
  DesignItem(
    index: 14,
    title: 'Бамбуковая роща',
    catalogId: 'seigaiha',
    image: 'assets/design/work-15.jpg',
    collection: 3,
    tags: <String>['Природа', 'Минимализм', 'Искусство'],
    detailTags: <String>['Природа', 'Бамбук', 'Свет', 'Япония'],
    description:
        'Зелёный коридор бамбука с мягким светом в конце тропы.',
    palette: kGreenPalette,
    popularity: 77,
    similar: <int>[15, 8, 10, 2],
  ),
  DesignItem(
    index: 15,
    title: 'Осенний мост',
    catalogId: 'asanoha',
    image: 'assets/design/work-16.jpg',
    collection: 0,
    tags: <String>['Природа', 'Искусство', 'Лето'],
    detailTags: <String>['Природа', 'Осень', 'Мост', 'Япония'],
    description:
        'Алый мост над водой среди клёнов, отражение и тёплая осенняя палитра.',
    palette: kAutumnPalette,
    popularity: 82,
    similar: <int>[1, 0, 5, 12],
  ),
];
