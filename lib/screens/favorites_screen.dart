// ═══════════════════════════════════════════════════════════════
//  ForaTV - Favorites Screen
//  Three tabs: Movies, Series, Channels
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../services/favorites_service.dart';
import '../utils/tv_focus_helper.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _movies = [];
  List<Map<String, dynamic>> _series = [];
  List<Map<String, dynamic>> _channels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final movies = await FavoritesService.getFavoriteMovies();
    final series = await FavoritesService.getFavoriteSeries();
    final channels = await FavoritesService.getFavoriteChannels();
    if (mounted) {
      setState(() {
        _movies = movies;
        _series = series;
        _channels = channels;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeMovie(String id) async {
    await FavoritesService.removeFavoriteMovie(id);
    _loadFavorites();
  }

  Future<void> _removeSeries(String id) async {
    await FavoritesService.removeFavoriteSeries(id);
    _loadFavorites();
  }

  Future<void> _removeChannel(String id) async {
    await FavoritesService.removeFavoriteChannel(id);
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAr = provider.locale == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: provider.isDarkMode ? AppColors.bgGradient : null,
          color: provider.isDarkMode ? null : AppColors.bgLightPrimary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 16, 12),
                child: Row(
                  children: [
                    TVFocusable(
                      borderRadius: 15,
                      onSelect: () => Navigator.pop(context),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: provider.isDarkMode
                              ? AppColors.glassBg
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: provider.isDarkMode
                                  ? AppColors.glassBorder
                                  : Colors.grey.shade200,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: Icon(
                          Iconsax.arrow_left_1,
                          color: provider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'المفضلة' : 'Favorites',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: provider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            isAr
                                ? 'محتواك المفضل في مكان واحد'
                                : 'All your favorites in one place',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.neonPink.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.heart,
                        color: AppColors.neonPink,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: provider.isDarkMode
                      ? AppColors.glassBg
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: provider.isDarkMode
                        ? AppColors.glassBorder
                        : Colors.grey.shade200,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.video, size: 16),
                          const SizedBox(width: 6),
                          Text(isAr ? 'أفلام' : 'Movies'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.video_play, size: 16),
                          const SizedBox(width: 6),
                          Text(isAr ? 'مسلسلات' : 'Series'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.monitor, size: 16),
                          const SizedBox(width: 6),
                          Text(isAr ? 'قنوات' : 'Channels'),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 10),

              // Tab Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMoviesTab(isAr, provider),
                          _buildSeriesTab(isAr, provider),
                          _buildChannelsTab(isAr, provider),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Movies Tab ─────────────────────────────────────────────
  Widget _buildMoviesTab(bool isAr, AppProvider provider) {
    if (_movies.isEmpty) {
      return _buildEmptyState(
        isAr ? 'لا توجد أفلام مفضلة' : 'No favorite movies',
        Iconsax.video,
      );
    }
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemCount: _movies.length,
        itemBuilder: (ctx, i) {
          final movie = _movies[i];
          final name = movie['name'] ?? '';
          final poster = movie['stream_icon'] ?? '';
          final id = movie['stream_id']?.toString() ?? '';

          return TVFocusable(
            borderRadius: 14,
            onSelect: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(movie: movie),
                ),
              ).then((_) => _loadFavorites());
            },
            child: GestureDetector(
              onLongPress: () => _showRemoveDialog(
                isAr,
                name,
                () => _removeMovie(id),
                provider,
              ),
              child:
                  Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: provider.isDarkMode
                                ? AppColors.glassBorder
                                : Colors.grey.shade200,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            poster.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: poster,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.video,
                                        color: AppColors.textMuted,
                                        size: 30,
                                      ),
                                    ),
                                  ),
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
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // Favorite badge
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Iconsax.heart,
                                  color: AppColors.neonPink,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 40 * (i % 15)))
                      .scale(begin: const Offset(0.92, 0.92)),
            ),
          );
        },
      ),
    );
  }

  // ─── Series Tab ─────────────────────────────────────────────
  Widget _buildSeriesTab(bool isAr, AppProvider provider) {
    if (_series.isEmpty) {
      return _buildEmptyState(
        isAr ? 'لا توجد مسلسلات مفضلة' : 'No favorite series',
        Iconsax.video_play,
      );
    }
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemCount: _series.length,
        itemBuilder: (ctx, i) {
          final series = _series[i];
          final name = series['name'] ?? '';
          final cover = series['cover'] ?? '';
          final id = series['series_id']?.toString() ?? '';

          return TVFocusable(
            borderRadius: 14,
            onSelect: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SeriesDetailScreen(series: series),
                ),
              ).then((_) => _loadFavorites());
            },
            child: GestureDetector(
              onLongPress: () => _showRemoveDialog(
                isAr,
                name,
                () => _removeSeries(id),
                provider,
              ),
              child:
                  Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: provider.isDarkMode
                                ? AppColors.glassBorder
                                : Colors.grey.shade200,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            cover.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: cover,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.video_play,
                                        color: AppColors.textMuted,
                                        size: 30,
                                      ),
                                    ),
                                  ),
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
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Iconsax.heart,
                                  color: AppColors.neonPink,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 40 * (i % 15)))
                      .scale(begin: const Offset(0.92, 0.92)),
            ),
          );
        },
      ),
    );
  }

  // ─── Channels Tab ───────────────────────────────────────────
  Widget _buildChannelsTab(bool isAr, AppProvider provider) {
    if (_channels.isEmpty) {
      return _buildEmptyState(
        isAr ? 'لا توجد قنوات مفضلة' : 'No favorite channels',
        Iconsax.monitor,
      );
    }
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemCount: _channels.length,
        itemBuilder: (ctx, i) {
          final channel = _channels[i];
          final name = channel['name'] ?? '';
          final logo = channel['stream_icon'] ?? '';
          final id = channel['stream_id']?.toString() ?? '';

          return TVFocusable(
            borderRadius: 14,
            onSelect: () {
              final url = provider.xtream.getLiveStreamUrl(id);
              // بناء قائمة القنوات المفضلة الحالية للتنقل داخل المشغل
              final channelList = _channels.map<Map<String, dynamic>>((c) {
                final cId = c['stream_id']?.toString() ?? '';
                return {
                  'url': provider.xtream.getLiveStreamUrl(cId),
                  'title': c['name'] ?? '',
                  'logo': c['stream_icon'] ?? '',
                  'name': c['name'] ?? '',
                };
              }).toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(
                    title: name,
                    url: url,
                    isLive: true,
                    channels: channelList,
                    currentChannelIndex: i,
                  ),
                ),
              );
            },
            child: GestureDetector(
              onLongPress: () => _showRemoveDialog(
                isAr,
                name,
                () => _removeChannel(id),
                provider,
              ),
              child:
                  Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: provider.isDarkMode
                                ? AppColors.glassBorder
                                : Colors.grey.shade200,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            logo.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: logo,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Iconsax.monitor,
                                        color: AppColors.textMuted,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(6, 18, 6, 6),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black87,
                                      Colors.transparent,
                                    ],
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
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // Favorite badge
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Iconsax.heart,
                                  color: AppColors.neonPink,
                                  size: 14,
                                ),
                              ),
                            ),
                            // LIVE badge
                            Positioned(
                              top: 5,
                              left: 5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.record,
                                      color: Colors.white,
                                      size: 6,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 40 * (i % 12)))
                      .scale(begin: const Offset(0.92, 0.92)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 70,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  void _showRemoveDialog(
    bool isAr,
    String name,
    VoidCallback onRemove,
    AppProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: provider.isDarkMode
                ? AppColors.glassBorder
                : Colors.grey.shade200,
          ),
        ),
        title: Text(
          isAr ? 'إزالة من المفضلة' : 'Remove from Favorites',
          style: TextStyle(
            color: provider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          isAr
              ? 'هل تريد إزالة "$name" من المفضلة؟'
              : 'Remove "$name" from favorites?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TVFocusable(
            borderRadius: 8,
            onSelect: () => Navigator.pop(ctx),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isAr ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
          TVFocusable(
            borderRadius: 8,
            focusColor: AppColors.danger,
            onSelect: () {
              Navigator.pop(ctx);
              onRemove();
            },
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onRemove();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: Text(isAr ? 'إزالة' : 'Remove'),
            ),
          ),
        ],
      ),
    );
  }
}
