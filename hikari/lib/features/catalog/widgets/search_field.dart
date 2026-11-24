import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikari/app/providers.dart';
import 'package:hikari/core/theme/app_colors.dart';
import 'package:hikari/core/theme/app_text.dart';

/// Поиск по названию, коллекции, тегу и HEX-цвету.
class HikariSearchField extends ConsumerStatefulWidget {
  const HikariSearchField({
    super.key,
    this.hint = 'Поиск: название, коллекция, тег или #C9362B',
    this.autofocus = false,
  });

  final String hint;
  final bool autofocus;

  @override
  ConsumerState<HikariSearchField> createState() => _HikariSearchFieldState();
}

class _HikariSearchFieldState extends ConsumerState<HikariSearchField> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(catalogFiltersProvider).query,
    );
    _controller.addListener(_onControllerChanged);
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onControllerChanged() {
    final text = _controller.text;
    final current = ref.read(catalogFiltersProvider).query;
    if (text != current) {
      ref.read(catalogFiltersProvider.notifier).setQuery(text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(catalogFiltersProvider.select((f) => f.query));

    // Сброс фильтров извне должен очищать поле.
    ref.listen<String>(catalogFiltersProvider.select((f) => f.query), (previous, next) {
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.sumi.withValues(alpha: _focus.hasFocus ? 0.12 : 0.04),
            blurRadius: _focus.hasFocus ? 28 : 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        cursorColor: theme.colorScheme.primary,
        style: AppText.body(14.5, color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 21,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: query.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                )
              : IconButton(
                  tooltip: 'Очистить',
                  onPressed: () {
                    _controller.clear();
                    ref.read(catalogFiltersProvider.notifier).setQuery('');
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
        ),
      ),
    );
  }
}
