// ═══════════════════════════════════════════════════════════════
//  ForaTV - Movies (VOD) Screen
//  Categories + Movie cards with poster images
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'player_screen.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});
  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<dynamic> _movies = [];
  String? _selectedCategory;
  bool _isLoading = false;
  final _searchCtrl = TextEditingController();
  List<dynamic> _filteredMovies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMovies([String? categoryId]) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = categoryId;
    });
    final provider = context.read<AppProvider>();
    _movies = await provider.xtream.getVodStreams(categoryId);
    _filteredMovies = _movies;
    setState(() => _isLoading = false);
  }

  void _filterMovies(String query) {
    setState(() {
      _filteredMovies = query.isEmpty
          ? _movies
          : _movies
                .where(
                  (m) => (m['name'] ?? '').toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().vodCategories;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filterMovies,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                hintText: 'بحث عن فيلم...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Categories
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0)
                return _buildCategoryChip(
                  'الكل',
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

        // Movie Grid
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _filteredMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 60,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'لا توجد أفلام',
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
                  itemCount: _filteredMovies.length,
                  itemBuilder: (ctx, i) =>
                      _buildMovieCard(_filteredMovies[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, String? id, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () => _loadMovies(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.glassBorder,
            ),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie, int index) {
    final name = movie['name'] ?? '';
    final poster = movie['stream_icon'] ?? '';
    final rating = movie['rating']?.toString() ?? '';
    final streamId = movie['stream_id']?.toString() ?? '';
    final ext = movie['container_extension'] ?? 'mp4';

    return GestureDetector(
      onTap: () {
        final url = context.read<AppProvider>().xtream.getVodStreamUrl(
          streamId,
          ext,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(title: name, url: url, isLive: false),
          ),
        );
      },
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
                    // Poster
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          poster.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: poster,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Icons.movie,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Icons.movie,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: AppColors.textMuted,
                                      size: 30,
                                    ),
                                  ),
                                ),
                          // Rating Badge
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
                    // Title
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
