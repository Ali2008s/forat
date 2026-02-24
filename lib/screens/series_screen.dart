// ═══════════════════════════════════════════════════════════════
//  ForaTV - Series Screen
//  Categories + Series cards with seasons/episodes navigation
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
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries([String? categoryId]) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = categoryId;
    });
    _series = await context.read<AppProvider>().xtream.getSeries(categoryId);
    setState(() => _isLoading = false);
  }

  void _openSeries(Map<String, dynamic> series) async {
    final seriesId = series['series_id']?.toString() ?? '';
    final name = series['name'] ?? '';
    final cover = series['cover'] ?? '';

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final info = await context.read<AppProvider>().xtream.getSeriesInfo(
      seriesId,
    );
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (info == null) return;

    final seasons = info['episodes'] as Map<String, dynamic>? ?? {};

    // Show seasons/episodes bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SeasonsSheet(
        title: name,
        cover: cover,
        seasons: seasons,
        xtream: context.read<AppProvider>().xtream,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().seriesCategories;

    return Column(
      children: [
        // Categories
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0)
                return _buildChip('الكل', null, _selectedCategory == null);
              final cat = categories[i - 1];
              return _buildChip(
                cat['category_name'] ?? '',
                cat['category_id']?.toString(),
                _selectedCategory == cat['category_id']?.toString(),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _series.isEmpty
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
                      const Text(
                        'لا توجد مسلسلات',
                        style: TextStyle(
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
                  itemCount: _series.length,
                  itemBuilder: (ctx, i) => _buildSeriesCard(_series[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildChip(String name, String? id, bool selected) {
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
                  borderRadius: BorderRadius.circular(14),
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
                                  placeholder: (_, __) => Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Icons.tv,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Icons.tv,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.tv,
                                      color: AppColors.textMuted,
                                      size: 30,
                                    ),
                                  ),
                                ),
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
              .fadeIn(delay: Duration(milliseconds: 30 * (index % 15)))
              .scale(begin: const Offset(0.92, 0.92)),
    );
  }
}

// ─── Seasons/Episodes Bottom Sheet ──────────────────────────────
class _SeasonsSheet extends StatefulWidget {
  final String title;
  final String cover;
  final Map<String, dynamic> seasons;
  final dynamic xtream;

  const _SeasonsSheet({
    required this.title,
    required this.cover,
    required this.seasons,
    required this.xtream,
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
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            // Season Tabs
            SizedBox(
              height: 40,
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
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: _selectedSeason == s
                                  ? AppColors.primaryGradient
                                  : null,
                              color: _selectedSeason == s
                                  ? null
                                  : AppColors.glassBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedSeason == s
                                    ? Colors.transparent
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              'الموسم $s',
                              style: TextStyle(
                                color: _selectedSeason == s
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Episodes List
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: episodes.length,
                itemBuilder: (ctx, i) {
                  final ep = episodes[i] as Map<String, dynamic>;
                  final title =
                      ep['title'] ?? 'الحلقة ${ep['episode_num'] ?? i + 1}';
                  final epId = ep['id']?.toString() ?? '';
                  final ext = ep['container_extension'] ?? 'mp4';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.glassBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.play_circle_fill,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      onTap: () {
                        final url = widget.xtream.getSeriesStreamUrl(epId, ext);
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
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * i));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
