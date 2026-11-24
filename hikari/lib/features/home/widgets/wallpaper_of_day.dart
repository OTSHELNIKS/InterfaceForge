import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/data/models/catalog_data.dart';
import 'package:hikari/data/models/hikari_item.dart';

/// Большая карточка «Обои дня».
class WallpaperOfDayCard extends StatelessWidget {
  const WallpaperOfDayCard({
    super.key,
    required this.item,
    required this.data,
    required this.onOpen,
    this.onApply,
  });

  final HikariItem item;
  final CatalogData data;
  final VoidCallback onOpen;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final collection = data.collectionById(item.collectionId);
    final wide = MediaQuery.sizeOf(context).width >= 880;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = wide ? 380.0 : 300.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(32),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onOpen,
                  child: SizedBox(
                    height: height,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          wide ? item.assetLandscape : item.asset,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.02),
                                Colors.black.withValues(alpha: 0.22),
                                Colors.black.withValues(alpha: 0.58),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.28),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.wb_sunny_rounded,
                                              size: 13,
                                              color: AppColors.gold,
                                            ),
                                            const SizedBox(width: 7),
                                            Text(
                                              'ОБОИ ДНЯ · 光',
                                              style: AppText.label(
                                                9.5,
                                                color: AppColors.card,
                                                letterSpacing: 0.18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 20,
                                        color: AppColors.card.withValues(alpha: 0.7),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    item.title,
                                    style: AppText.display(
                                      wide ? 48 : 34,
                                      color: AppColors.card,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        item.titleJa,
                                        style: AppText.mincho(
                                          15,
                                          color: AppColors.sakura,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          '·',
                                          style: AppText.body(
                                            12,
                                            color: AppColors.card.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        collection?.name ?? '',
                                        style: AppText.body(
                                          12,
                                          color: AppColors.card.withValues(alpha: 0.7),
                                          letterSpacing: 0.08,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (onApply != null)
                          Positioned(
                            right: 24,
                            bottom: 24,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Material(
                                  color: Colors.black.withValues(alpha: 0.26),
                                  shape: const StadiumBorder(),
                                  child: InkWell(
                                    customBorder: const StadiumBorder(),
                                    onTap: onApply,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.download_rounded,
                                            size: 16,
                                            color: AppColors.card,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Установить',
                                            style: AppText.label(
                                              11,
                                              color: AppColors.card,
                                              letterSpacing: 0.08,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
