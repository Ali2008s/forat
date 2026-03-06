// ═══════════════════════════════════════════════════════════════
//  ForaTV - Series Detail Screen
//  Full-page series info: cover, name, description, rating,
//  seasons/episodes, download, favorites
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';
import '../services/favorites_service.dart';
import '../providers/download_provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'player_screen.dart';

class SeriesDetailScreen extends StatefulWidget {
  final Map<String, dynamic> series;
  const SeriesDetailScreen({super.key, required this.series});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  Map<String, dynamic>? _seriesInfo;
  Map<String, dynamic> _seasons = {};
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _selectedSeason;

  @override
  void initState() {
    super.initState();
    _loadInfo();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final id = widget.series['series_id']?.toString() ?? '';
    final fav = await FavoritesService.isSeriesFavorite(id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final id = widget.series['series_id']?.toString() ?? '';
    if (_isFavorite) {
      await FavoritesService.removeFavoriteSeries(id);
    } else {
      await FavoritesService.addFavoriteSeries(widget.series);
    }
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _loadInfo() async {
    final provider = context.read<AppProvider>();
    final seriesId = widget.series['series_id']?.toString() ?? '';
    final info = await provider.xtream.getSeriesInfo(seriesId);
    if (mounted) {
      setState(() {
        _seriesInfo = info;
        _seasons = (info?['episodes'] as Map<String, dynamic>?) ?? {};
        if (_seasons.isNotEmpty) _selectedSeason = _seasons.keys.first;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadEpisode(
    Map<String, dynamic> ep,
    String seriesName,
  ) async {
    final provider = context.read<AppProvider>();
    final downloadProvider = context.read<DownloadProvider>();
    final isAr = provider.locale == 'ar';

    final title = ep['title'] ?? 'Episode ${ep['episode_num'] ?? ''}';
    final epId = (ep['id'] ?? ep['stream_id'])?.toString() ?? '';
    if (epId.isEmpty) {
      debugPrint('SeriesDetail: Episode ID is missing! ${ep.keys}');
    }

    final cover = ep['stream_icon']?.toString() ?? widget.series['cover'] ?? '';
    String ext = (ep['container_extension']?.toString() ?? '').trim();
    if (ext.isEmpty || ext == 'null') ext = 'mp4';
    final url = provider.xtream.getSeriesStreamUrl(epId, ext);

    debugPrint('SeriesDetail: Starting download for $title ID=$epId URL=$url');

    downloadProvider.startDownload(
      id: epId,
      title: title,
      type: 'series',
      coverUrl: cover,
      url: url,
      ext: ext,
      seriesFolder: seriesName,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? 'بدأ تحميل "$title"...' : 'Downloading "$title"...',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _downloadAllEpisodes(
    List<dynamic> episodes,
    String seriesName,
  ) async {
    final provider = context.read<AppProvider>();
    final downloadProvider = context.read<DownloadProvider>();
    final isAr = provider.locale == 'ar';

    for (int i = 0; i < episodes.length; i++) {
      final ep = episodes[i] as Map<String, dynamic>;
      final title = ep['title'] ?? 'Episode ${ep['episode_num'] ?? i + 1}';
      final epId = (ep['stream_id'] ?? ep['id'])?.toString() ?? '';
      final cover =
          ep['stream_icon']?.toString() ?? widget.series['cover'] ?? '';
      String ext = (ep['container_extension']?.toString() ?? '').trim();
      if (ext.isEmpty || ext == 'null') ext = 'mp4';
      final url = provider.xtream.getSeriesStreamUrl(epId, ext);

      downloadProvider.startDownload(
        id: epId,
        title: title,
        type: 'series',
        coverUrl: cover,
        url: url,
        ext: ext,
        seriesFolder: seriesName,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'تمت إضافة جميع الحلقات لقائمة التنزيلات'
                : 'All episodes added to downloads',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showDownloadDialog(List<dynamic> episodes) {
    final provider = context.read<AppProvider>();
    final isAr = provider.locale == 'ar';
    final seriesName = widget.series['name'] ?? 'series';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(Iconsax.document_download, size: 50, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              isAr ? 'خيارات التحميل' : 'Download Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? '${episodes.length} حلقة متوفرة'
                  : '${episodes.length} episodes available',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Download all
            _buildDownloadOption(
              icon: Iconsax.tick_circle,
              title: isAr ? 'تحميل جميع الحلقات' : 'Download All Episodes',
              subtitle: isAr
                  ? 'سيتم تحميل كل الحلقات تلقائياً'
                  : 'All episodes will be downloaded',
              gradient: AppColors.primaryGradient,
              onTap: () {
                Navigator.pop(ctx);
                _downloadAllEpisodes(episodes, seriesName);
              },
            ),
            const SizedBox(height: 12),
            // Download specific
            _buildDownloadOption(
              icon: Iconsax.task,
              title: isAr ? 'اختيار حلقة معينة' : 'Choose Specific Episode',
              subtitle: isAr
                  ? 'اختر الحلقة التي تريد تحميلها'
                  : 'Select which episode to download',
              gradient: AppColors.neonGradient,
              onTap: () {
                Navigator.pop(ctx);
                _showEpisodePickerForDownload(episodes, seriesName);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEpisodePickerForDownload(
    List<dynamic> episodes,
    String seriesName,
  ) {
    final provider = context.read<AppProvider>();
    final isAr = provider.locale == 'ar';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
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
                padding: const EdgeInsets.all(20),
                child: Text(
                  isAr ? 'اختر حلقة للتحميل' : 'Select Episode to Download',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.glassBorder),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: episodes.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) {
                    final ep = episodes[i] as Map<String, dynamic>;
                    final title =
                        ep['title'] ??
                        (isAr
                            ? 'الحلقة ${ep['episode_num'] ?? i + 1}'
                            : 'EP ${ep['episode_num'] ?? i + 1}');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: provider.isDarkMode
                            ? AppColors.glassBg
                            : Colors.white60,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: provider.isDarkMode
                              ? AppColors.glassBorder
                              : Colors.black12,
                        ),
                      ),
                      child: ListTile(
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
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        trailing: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppColors.neonGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.document_download,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _downloadEpisode(ep, seriesName);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAr = provider.locale == 'ar';
    final name = widget.series['name'] ?? '';
    final cover = widget.series['cover'] ?? '';
    final rating = widget.series['rating']?.toString() ?? '';

    // Extract info from seriesInfo
    final info = _seriesInfo?['info'] as Map<String, dynamic>? ?? {};
    final plot = info['plot']?.toString() ?? '';
    final genre = info['genre']?.toString() ?? '';
    final cast = info['cast']?.toString() ?? '';
    final director = info['director']?.toString() ?? '';
    final releaseDate = info['releaseDate']?.toString() ?? '';

    final episodes = _selectedSeason != null
        ? (_seasons[_selectedSeason] as List?) ?? []
        : [];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: provider.isDarkMode ? AppColors.bgGradient : null,
          color: provider.isDarkMode ? null : AppColors.bgLightPrimary,
        ),
        child: CustomScrollView(
          slivers: [
            // Hero cover
            SliverAppBar(
              expandedHeight: 380,
              pinned: true,
              backgroundColor: AppColors.bgDark,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.arrow_left_1,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isFavorite ? Iconsax.heart : Iconsax.heart,
                      color: _isFavorite ? AppColors.neonPink : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    cover.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: cover,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Iconsax.video_play,
                                color: AppColors.textMuted,
                                size: 60,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surface,
                            child: const Icon(
                              Iconsax.video_play,
                              color: AppColors.textMuted,
                              size: 60,
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            provider.isDarkMode
                                ? const Color(0xCC120D1C)
                                : Colors.white.withValues(alpha: 0.7),
                            provider.isDarkMode
                                ? const Color(0xFF120D1C)
                                : AppColors.bgLightPrimary,
                          ],
                          stops: const [0.0, 0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          height: 1.2,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 12),

                      // Info chips
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (rating.isNotEmpty &&
                              rating != '0' &&
                              rating != 'null')
                            _buildChip(
                              icon: Iconsax.star,
                              label: rating,
                              color: AppColors.warning,
                            ),
                          if (genre.isNotEmpty && genre != 'null')
                            _buildChip(
                              icon: Iconsax.category,
                              label: genre,
                              color: AppColors.accent,
                            ),
                          if (_seasons.isNotEmpty)
                            _buildChip(
                              icon: Iconsax.video_vertical,
                              label:
                                  '${_seasons.length} ${isAr ? "مواسم" : "Seasons"}',
                              color: AppColors.cyan,
                            ),
                          if (releaseDate.isNotEmpty && releaseDate != 'null')
                            _buildChip(
                              icon: Iconsax.calendar,
                              label: releaseDate,
                              color: AppColors.info,
                            ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 25),

                      // Season Tabs + Download button
                      if (_seasons.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isAr
                                    ? 'المواسم والحلقات'
                                    : 'Seasons & Episodes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                ),
                              ),
                            ),
                            // Download button for episodes
                            if (episodes.isNotEmpty)
                              TVFocusable(
                                borderRadius: 20,
                                focusColor: AppColors.neonPink,
                                onSelect: () => _showDownloadDialog(episodes),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.neonGradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Iconsax.document_download,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isAr ? 'تحميل' : 'Download',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ).animate().fadeIn(delay: 250.ms),
                        const SizedBox(height: 12),
                        // Season tabs
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _seasons.keys
                                .map(
                                  (s) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: TVFocusable(
                                      borderRadius: 20,
                                      onSelect: () =>
                                          setState(() => _selectedSeason = s),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
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
                                              : (provider.isDarkMode
                                                    ? AppColors.glassBg
                                                    : Colors.grey.shade100),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _selectedSeason == s
                                                ? Colors.transparent
                                                : (provider.isDarkMode
                                                      ? AppColors.glassBorder
                                                      : Colors.grey.shade200),
                                          ),
                                        ),
                                        child: Text(
                                          '${isAr ? "الموسم" : "S"} $s',
                                          style: TextStyle(
                                            color: _selectedSeason == s
                                                ? Colors.white
                                                : (provider.isDarkMode
                                                      ? AppColors.textSecondary
                                                      : Colors.black87),
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
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 8),
                        // Episodes count
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '${episodes.length} ${isAr ? "حلقة" : "episodes"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description (MOVED DOWN)
                      if (plot.isNotEmpty && plot != 'null') ...[
                        Text(
                          isAr ? 'الوصف' : 'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: provider.isDarkMode
                                ? AppColors.glassBg
                                : Colors.white60,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: provider.isDarkMode
                                  ? AppColors.glassBorder
                                  : Colors.black12,
                            ),
                          ),
                          child: Text(
                            plot,
                            style: TextStyle(
                              color: provider.isDarkMode
                                  ? AppColors.textSecondary
                                  : Colors.black87,
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 16),
                      ],

                      // Director & Cast (MOVED DOWN)
                      if (director.isNotEmpty && director != 'null')
                        _buildInfoRow2(
                          icon: Iconsax.video_circle,
                          label: isAr ? 'المخرج' : 'Director',
                          value: director,
                        ).animate().fadeIn(delay: 500.ms),

                      if (cast.isNotEmpty && cast != 'null')
                        _buildInfoRow2(
                          icon: Iconsax.user_tag,
                          label: isAr ? 'الممثلون' : 'Cast',
                          value: cast,
                        ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 20),

                      // Loading spinner for info
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Episodes list
            if (!_isLoading && episodes.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final ep = episodes[i] as Map<String, dynamic>;
                    final title =
                        ep['title'] ??
                        (isAr
                            ? 'الحلقة ${ep['episode_num'] ?? i + 1}'
                            : 'EP ${ep['episode_num'] ?? i + 1}');
                    final epId =
                        (ep['stream_id'] ?? ep['id'])?.toString() ?? '';
                    String ext = (ep['container_extension']?.toString() ?? '')
                        .trim();
                    if (ext.isEmpty || ext == 'null') ext = 'mp4';
                    final epInfo = ep['info'] as Map<String, dynamic>? ?? {};
                    final duration = epInfo['duration_secs'] != null
                        ? _formatDuration(
                            int.tryParse(epInfo['duration_secs'].toString()) ??
                                0,
                          )
                        : '';

                    return TVFocusableListItem(
                          onSelect: () {
                            final url = provider.xtream.getSeriesStreamUrl(
                              epId,
                              ext,
                            );
                            final episodeList = episodes
                                .map<Map<String, dynamic>>((e) {
                                  final eMap = e as Map<String, dynamic>;
                                  final eId =
                                      (eMap['stream_id'] ?? eMap['id'])
                                          ?.toString() ??
                                      '';
                                  String eExt =
                                      (eMap['container_extension']
                                                  ?.toString() ??
                                              '')
                                          .trim();
                                  if (eExt.isEmpty || eExt == 'null') {
                                    eExt = 'mp4';
                                  }
                                  final eTitle =
                                      eMap['title'] ??
                                      (isAr
                                          ? 'الحلقة ${eMap['episode_num'] ?? ''}'
                                          : 'EP ${eMap['episode_num'] ?? ''}');
                                  return {
                                    'url': provider.xtream.getSeriesStreamUrl(
                                      eId,
                                      eExt,
                                    ),
                                    'title': eTitle,
                                    'episode': eMap['episode_num'] ?? '',
                                  };
                                })
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  title: title,
                                  url: url,
                                  isLive: false,
                                  episodes: episodeList,
                                  currentEpisodeIndex: i,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.glassBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
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
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: duration.isNotEmpty
                                  ? Text(
                                      duration,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    )
                                  : null,
                              trailing: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.play,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 40 * (i % 10)))
                        .slideX(begin: 0.05);
                  }, childCount: episodes.length),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow2({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.read<AppProvider>().isDarkMode
                      ? AppColors.textMuted
                      : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
