// ═══════════════════════════════════════════════════════════════
//  ForaTV - Series Screen
//  Categories + Series cards + Seasons/Episodes Navigation + Live Search
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'player_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});
  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<dynamic> _series = [];
  List<dynamic> _filteredSeries = [];
  String? _selectedCategory;
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

  Future<void> _loadSeries([String? categoryId]) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = categoryId;
      _searchCtrl.clear();
    });
    final provider = context.read<AppProvider>();
    _series = await provider.xtream.getSeries(categoryId);
    _filteredSeries = _series;
    setState(() => _isLoading = false);
  }

  void _filterSeries(String query) {
    setState(() {
      _filteredSeries = query.isEmpty
          ? _series
          : _series
                .where(
                  (s) => (s['name'] ?? '').toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
    });
  }

  void _openSeries(Map<String, dynamic> series) async {
    final seriesId = series['series_id']?.toString() ?? '';
    final name = series['name'] ?? '';
    final cover = series['cover'] ?? '';
    final provider = context.read<AppProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final info = await provider.xtream.getSeriesInfo(seriesId);
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (info == null) return;
    final seasons = info['episodes'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SeasonsSheet(
        title: name,
        cover: cover,
        seasons: seasons,
        xtream: provider.xtream,
        isAr: provider.locale == 'ar',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = provider.seriesCategories;
    final isAr = provider.locale == 'ar';

    return Column(
      children: [
        // Search toggle + Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showSearch
                ? Container(
                    key: const ValueKey('search'),
                    decoration: BoxDecoration(
                      color: AppColors.glassBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _filterSeries,
                      autofocus: true,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.close,
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
                          fontSize: 13,
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
                        child: Text(
                          isAr ? 'المسلسلات' : 'Series',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showSearch = true),
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Categories Chips
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0)
                return _buildCategoryChip(
                  isAr ? 'الكل' : 'All',
                  null,
                  _selectedCategory == null,
                );
              final cat = categories[i - 1];
              return _buildCategoryChip(
                cat['category_name'] ?? '',
                cat['category_id']?.toString(),
                _selectedCategory == cat['category_id']?.toString(),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

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
                        Icons.tv,
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
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: _filteredSeries.length,
                  itemBuilder: (ctx, i) =>
                      _buildSeriesCard(_filteredSeries[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, String? id, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () => _loadSeries(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.glassBg,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.glassBorder,
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesCard(Map<String, dynamic> series, int index) {
    final name = series['name'] ?? '';
    final cover = series['cover'] ?? '';
    final rating = series['rating']?.toString() ?? '';

    return GestureDetector(
      onTap: () => _openSeries(series),
      child:
          Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          cover.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: cover,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      _buildPosterPlaceholder(),
                                  errorWidget: (_, __, ___) =>
                                      _buildPosterPlaceholder(),
                                )
                              : _buildPosterPlaceholder(),
                          if (rating.isNotEmpty &&
                              rating != '0' &&
                              rating != 'null')
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.warning,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * (index % 15)))
              .scale(begin: const Offset(0.92, 0.92)),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.tv, color: AppColors.textMuted, size: 30),
      ),
    );
  }
}

// ─── Seasons/Episodes Bottom Sheet ──────────────────────────────
class _SeasonsSheet extends StatefulWidget {
  final String title;
  final String cover;
  final Map<String, dynamic> seasons;
  final dynamic xtream;
  final bool isAr;

  const _SeasonsSheet({
    required this.title,
    required this.cover,
    required this.seasons,
    required this.xtream,
    required this.isAr,
  });

  @override
  State<_SeasonsSheet> createState() => _SeasonsSheetState();
}

class _SeasonsSheetState extends State<_SeasonsSheet> {
  String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    if (widget.seasons.isNotEmpty) _selectedSeason = widget.seasons.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final episodes = _selectedSeason != null
        ? (widget.seasons[_selectedSeason] as List?) ?? []
        : [];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.cover.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.cover,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 70,
                            color: AppColors.glassBg,
                            child: const Icon(Icons.tv),
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          '${widget.seasons.length} ${widget.isAr ? "مواسم" : "Seasons"}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.glassBorder),
            const SizedBox(height: 10),
            // Season Tabs
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: widget.seasons.keys
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSeason = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: _selectedSeason == s
                                  ? AppColors.primaryGradient
                                  : null,
                              color: _selectedSeason == s
                                  ? null
                                  : AppColors.glassBg,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _selectedSeason == s
                                    ? Colors.transparent
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              '${widget.isAr ? "الموسم" : "Season"} $s',
                              style: TextStyle(
                                color: _selectedSeason == s
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: _selectedSeason == s
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 15),
            // Episodes List
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                itemCount: episodes.length,
                itemBuilder: (ctx, i) {
                  final ep = episodes[i] as Map<String, dynamic>;
                  final title =
                      ep['title'] ??
                      (widget.isAr
                          ? 'الحلقة ${ep['episode_num'] ?? i + 1}'
                          : 'EP ${ep['episode_num'] ?? i + 1}');
                  final epId = ep['id']?.toString() ?? '';
                  final ext = ep['container_extension'] ?? 'mp4';

                  return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.glassBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 36,
                          ),
                          onTap: () {
                            final url = widget.xtream.getSeriesStreamUrl(
                              epId,
                              ext,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  title: title,
                                  url: url,
                                  isLive: false,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * (i % 10)))
                      .slideX(begin: 0.05);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
