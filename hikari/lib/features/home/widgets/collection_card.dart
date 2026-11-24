import 'package:material_ui/material_ui.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';
import 'package:hikari/data/models/hikari_collection.dart';

/// Карточка коллекции в горизонтальной ленте.
class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    required this.count,
    required this.onTap,
  });

  final HikariCollection collection;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 208,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: dark ? AppColors.sumiCard : AppColors.card,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sumi.withValues(alpha: dark ? 0.4 : 0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -6,
                top: -18,
                child: Text(
                  collection.nameJa,
                  style: AppText.kanji(
                    68,
                    color: collection.color.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: collection.color,
                          boxShadow: [
                            BoxShadow(
                              color: collection.color.withValues(alpha: 0.55),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        collection.name.toUpperCase(),
                        style: AppText.label(
                          9.5,
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    collection.name,
                    style: AppText.display(
                      23,
                      color: theme.colorScheme.onSurface,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    collection.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                      11.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$count ${_plural(count)}',
                    style: AppText.body(
                      11,
                      color: collection.color,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
