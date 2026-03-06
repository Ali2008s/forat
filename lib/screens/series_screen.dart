// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ForaTV - Series Screen
//  Categories popup + Series poster grid + Seasons/Episodes + Search
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';
import 'series_detail_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});
  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<dynamic> _allSeries = [];
  List<dynamic> _filteredSeries = [];
  String? _selectedCategory;
  String _selectedCategoryName = '';
  bool _isLoading = false;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSeries([String? categoryId, String? categoryName]) async {
    final provider = context.read<AppProvider>();

    setState(() {
      _selectedCategory = categoryId;
      _selectedCategoryName = categoryName ?? '';
      _searchCtrl.clear();
    });

    if (_allSeries.isEmpty) {
      if (mounted) setState(() => _isLoading = true);
      _allSeries = await provider.xtream.getSeries();
      if (mounted) setState(() => _isLoading = false);
    }

    setState(() {
      if (categoryId == null) {
        _filteredSeries = _allSeries;
      } else {
        _filteredSeries = _allSeries
            .where((s) => s['category_id'].toString() == categoryId)
            .toList();
      }
    });
  }

  void _filterSeries(String query) {
    setState(() {
      final baseList = _selectedCategory == null
          ? _allSeries
          : _allSeries
                .where((s) => s['category_id'].toString() == _selectedCategory)
                .toList();

      _filteredSeries = query.isEmpty
          ? baseList
          : baseList
                .where(
                  (s) => (s['name'] ?? '').toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
    });
  }

  void _showCategoriesSheet(
    BuildContext context,
    List<dynamic> categories,
    bool isAr,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SeriesCategoriesSheet(
        categories: categories,
        selectedId: _selectedCategory,
        isAr: isAr,
        onSelect: (id, name) {
          Navigator.pop(context);
          _loadSeries(id, name);
        },
      ),
    );
  }

  void _openSeries(Map<String, dynamic> series) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SeriesDetailScreen(series: series)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = provider.seriesCategories;
    final isAr = provider.locale == 'ar';

    return Column(
      children: [
        // Header: title + search + categories button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showSearch
                ? Container(
                    key: const ValueKey('search'),
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? AppColors.glassBg
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: provider.isDarkMode
                            ? AppColors.glassBorder
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _filterSeries,
                      autofocus: true,
                      style: TextStyle(
                        color: provider.isDarkMode
                            ? AppColors.textPrimary
                            : Colors.black87,
                        fontSize: 14,
                      ),
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Iconsax.search_normal_1,
                          color: AppColors.textMuted,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Iconsax.close_circle,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            _filterSeries('');
                            setState(() => _showSearch = false);
                          },
                        ),
                        hintText: isAr ? 'بحث عن مسلسل...' : 'Search series...',
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('header'),
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'المسلسلات' : 'Series',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                                letterSpacing: -1,
                              ),
                            ),
                            if (_selectedCategoryName.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: isAr
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          _selectedCategoryName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary.withValues(
                                              alpha: 0.9,
                                            ),
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Filter Button
                      if (categories.isNotEmpty)
                        TVFocusable(
                          autofocus: true,
                          borderRadius: 14,
                          onSelect: () =>
                              _showCategoriesSheet(context, categories, isAr),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: provider.isDarkMode
                                  ? AppColors.glassBg
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: provider.isDarkMode
                                    ? AppColors.glassBorder
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: provider.isDarkMode
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category,
                                  size: 18,
                                  color: provider.isDarkMode
                                      ? AppColors.textSecondary
                                      : Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isAr ? 'الأقسام' : 'Filter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: provider.isDarkMode
                                        ? AppColors.textSecondary
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Search Button
                      TVFocusable(
                        borderRadius: 14,
                        onSelect: () => setState(() => _showSearch = true),
                        child: IconButton(
                          onPressed: () => setState(() => _showSearch = true),
                          style: IconButton.styleFrom(
                            backgroundColor: provider.isDarkMode
                                ? AppColors.glassBg
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: provider.isDarkMode
                                    ? AppColors.glassBorder
                                    : Colors.grey.shade200,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: Icon(
                            Icons.search,
                            size: 20,
                            color: provider.isDarkMode
                                ? AppColors.textSecondary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (!_showSearch && !_isLoading && _filteredSeries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                '${_filteredSeries.length} ${isAr ? "مسلسل" : "series"}',
                style: TextStyle(
                  fontSize: 11,
                  color: provider.isDarkMode
                      ? AppColors.textMuted
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),

        const SizedBox(height: 6),

        // Series Grid
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _filteredSeries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.video_play,
                        size: 60,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isAr ? 'لا توجد مسلسلات' : 'No series found',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : FocusTraversalGroup(
                  policy: ReadingOrderTraversalPolicy(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: _filteredSeries.length,
                    itemBuilder: (ctx, i) =>
                        _buildSeriesCard(_filteredSeries[i], i),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSeriesCard(Map<String, dynamic> series, int index) {
    final name = series['name'] ?? '';
    final cover = series['cover'] ?? '';
    final rating = series['rating']?.toString() ?? '';

    return TVFocusable(
      autofocus: index == 0,
      borderRadius: 14,
      onSelect: () => _openSeries(series),
      child:
          Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.glassBorder
                        : Colors.grey.shade200,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover fills card
                    cover.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: cover,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildPosterPlaceholder(),
                            errorWidget: (_, __, ___) =>
                                _buildPosterPlaceholder(),
                          )
                        : _buildPosterPlaceholder(),
                    // Bottom gradient + title
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(6, 20, 6, 6),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black, Colors.transparent],
                          ),
                        ),
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Rating badge
                    if (rating.isNotEmpty && rating != '0' && rating != 'null')
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.star,
                                color: AppColors.warning,
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Play icon (center)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 30,
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.play,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 40 * (index % 15)))
              .scale(begin: const Offset(0.92, 0.92)),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Iconsax.video_play, color: AppColors.textMuted, size: 30),
      ),
    );
  }
}

// ─── Series Categories Sheet ──────────────────────────────────────────
class _SeriesCategoriesSheet extends StatefulWidget {
  final List<dynamic> categories;
  final String? selectedId;
  final bool isAr;
  final void Function(String? id, String name) onSelect;

  const _SeriesCategoriesSheet({
    required this.categories,
    required this.selectedId,
    required this.isAr,
    required this.onSelect,
  });

  @override
  State<_SeriesCategoriesSheet> createState() => _SeriesCategoriesSheetState();
}

class _SeriesCategoriesSheetState extends State<_SeriesCategoriesSheet> {
  final _searchCtrl = TextEditingController();
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? widget.categories
          : widget.categories
                .where(
                  (c) => (c['category_name'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(q.toLowerCase()),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isAr ? 'أقسام المسلسلات' : 'Series Categories',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.categories.length + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _filter,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Iconsax.search_normal_1,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    hintText: isAr
                        ? 'ابحث في الأقسام...'
                        : 'Search categories...',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.glassBorder),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _filtered.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _buildItem(
                      name: isAr ? '📺 الكل' : '📺 All',
                      id: null,
                      isSelected: widget.selectedId == null,
                      isAr: isAr,
                    );
                  }
                  final cat = _filtered[i - 1];
                  final id = cat['category_id']?.toString();
                  return _buildItem(
                    name: cat['category_name'] ?? '',
                    id: id,
                    isSelected: widget.selectedId == id,
                    isAr: isAr,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required String name,
    required String? id,
    required bool isSelected,
    required bool isAr,
  }) {
    return TVFocusableListItem(
      autofocus: isSelected,
      onSelect: () => widget.onSelect(id, name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.textMuted.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.primary)
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Iconsax.tick_circle,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
