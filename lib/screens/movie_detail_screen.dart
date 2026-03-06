// ═══════════════════════════════════════════════════════════════
//  ForaTV - Movie Detail Screen
//  Full-page movie info: poster, name, description, rating, download
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

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic>? _vodInfo;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final id = widget.movie['stream_id']?.toString() ?? '';
    final fav = await FavoritesService.isMovieFavorite(id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final id = widget.movie['stream_id']?.toString() ?? '';
    if (_isFavorite) {
      await FavoritesService.removeFavoriteMovie(id);
    } else {
      await FavoritesService.addFavoriteMovie(widget.movie);
    }
    if (mounted) setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _loadInfo() async {
    final provider = context.read<AppProvider>();
    final streamId = widget.movie['stream_id']?.toString() ?? '';
    final info = await provider.xtream.getVodInfo(streamId);
    if (mounted) {
      setState(() {
        _vodInfo = info;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadMovie() async {
    final provider = context.read<AppProvider>();
    final downloadProvider = context.read<DownloadProvider>();
    final isAr = provider.locale == 'ar';
    final name = widget.movie['name'] ?? 'movie';
    final streamId = widget.movie['stream_id']?.toString() ?? '';
    final poster = widget.movie['stream_icon'] ?? '';
    String ext = (widget.movie['container_extension']?.toString() ?? '').trim();
    if (ext.isEmpty || ext == 'null') ext = 'mp4';
    final url = provider.xtream.getVodStreamUrl(streamId, ext);

    downloadProvider.startDownload(
      id: streamId,
      title: name,
      type: 'movie',
      coverUrl: poster,
      url: url,
      ext: ext,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'بدأ التحميل...' : 'Download started...'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final downloadProvider = context.watch<DownloadProvider>();
    final isAr = provider.locale == 'ar';
    final name = widget.movie['name'] ?? '';
    final poster = widget.movie['stream_icon'] ?? '';
    final rating = widget.movie['rating']?.toString() ?? '';
    final streamId = widget.movie['stream_id']?.toString() ?? '';
    String ext = (widget.movie['container_extension']?.toString() ?? '').trim();
    if (ext.isEmpty || ext == 'null') ext = 'mp4';

    // Extract info from vodInfo
    final info = _vodInfo?['info'] as Map<String, dynamic>? ?? {};
    final plot = info['plot']?.toString() ?? '';
    final genre = info['genre']?.toString() ?? '';
    final duration = info['duration']?.toString() ?? '';
    final director = info['director']?.toString() ?? '';
    final cast = info['cast']?.toString() ?? '';
    final releaseDate = info['releasedate']?.toString() ?? '';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: provider.isDarkMode ? AppColors.bgGradient : null,
          color: provider.isDarkMode ? null : AppColors.bgLightPrimary,
        ),
        child: CustomScrollView(
          slivers: [
            // Hero poster
            SliverAppBar(
              expandedHeight: 400,
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
                    Iconsax.arrow_left,
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
                    poster.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: poster,
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
                                Iconsax.video,
                                color: AppColors.textMuted,
                                size: 60,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surface,
                            child: const Icon(
                              Iconsax.video,
                              color: AppColors.textMuted,
                              size: 60,
                            ),
                          ),
                    // Gradient overlay
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
                                : Colors.white.withOpacity(0.7),
                            provider.isDarkMode
                                ? const Color(0xFF120D1C)
                                : AppColors.bgLightPrimary,
                          ],
                          stops: const [0.0, 0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                    // Play button center
                    // Center(
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       final url = provider.xtream.getVodStreamUrl(
                    //         streamId,
                    //         ext,
                    //       );
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (_) => PlayerScreen(
                    //             title: name,
                    //             url: url,
                    //             isLive: false,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     // child: Container(
                    //     //   width: 70,
                    //     //   height: 70,
                    //     //   decoration: BoxDecoration(
                    //     //     gradient: AppColors.neonGradient,
                    //     //     shape: BoxShape.circle,
                    //     //     boxShadow: [
                    //     //       BoxShadow(
                    //     //         color: AppColors.primary.withOpacity(0.5),
                    //     //         blurRadius: 20,
                    //     //         spreadRadius: 2,
                    //     //       ),
                    //     //     ],
                    //     //   ),
                    //     //   child: const Icon(
                    //     //     Icons.play_arrow,
                    //     //     color: Colors.white,
                    //     //     size: 40,
                    //     //   ),
                    //     // ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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

                      // Rating + Genre + Duration row
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
                          if (duration.isNotEmpty && duration != 'null')
                            _buildChip(
                              icon: Iconsax.clock,
                              label: duration,
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

                      // Action Buttons
                      Row(
                        children: [
                          // Play Button
                          Expanded(
                            flex: 2,
                            child: _buildActionButton(
                              icon: Iconsax.play,
                              label: isAr ? 'تشغيل' : 'Play',
                              gradient: AppColors.primaryGradient,
                              onTap: () {
                                final url = provider.xtream.getVodStreamUrl(
                                  streamId,
                                  ext,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      title: name,
                                      url: url,
                                      isLive: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Download Button
                          Expanded(
                            flex: 2,
                            child: downloadProvider.isDownloading(streamId)
                                ? Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        LinearProgressIndicator(
                                          value: downloadProvider.getProgress(
                                            streamId,
                                          ),
                                          backgroundColor: Colors.white10,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                AppColors.primary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(downloadProvider.getProgress(streamId) * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _buildActionButton(
                                    icon: Iconsax.document_download,
                                    label: isAr ? 'تحميل' : 'Download',
                                    gradient: AppColors.neonGradient,
                                    onTap: _downloadMovie,
                                  ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                      const SizedBox(height: 30),

                      // Description
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
                                    : Colors.white70,
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
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .scale(begin: const Offset(0.95, 0.95)),
                        const SizedBox(height: 20),
                      ],

                      // Director
                      if (director.isNotEmpty && director != 'null')
                        _buildInfoRow(
                          icon: Iconsax.video_circle,
                          label: isAr ? 'المخرج' : 'Director',
                          value: director,
                        ).animate().fadeIn(delay: 500.ms),

                      // Cast
                      if (cast.isNotEmpty && cast != 'null')
                        _buildInfoRow(
                          icon: Iconsax.user_tag,
                          label: isAr ? 'الممثلون' : 'Cast',
                          value: cast,
                        ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 30),

                      // Loading indicator
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
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

  Widget _buildInfoRow({
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return TVFocusable(
      borderRadius: 16,
      focusColor: gradient.colors.first,
      onSelect: onTap,
      child: Container(
        height: 52,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
