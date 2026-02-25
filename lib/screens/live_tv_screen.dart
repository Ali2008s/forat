// ═══════════════════════════════════════════════════════════════
//  ForaTV - Live TV Screen
//  Categories + Channel grid + Live Search
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});
  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  List<dynamic> _channels = [];
  List<dynamic> _filteredChannels = [];
  String? _selectedCategory;
  bool _isLoading = false;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadChannels([String? categoryId]) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = categoryId;
      _searchCtrl.clear();
    });
    final provider = context.read<AppProvider>();
    _channels = await provider.xtream.getLiveStreams(categoryId);
    _filteredChannels = _channels;
    setState(() => _isLoading = false);
  }

  void _filterChannels(String query) {
    setState(() {
      _filteredChannels = query.isEmpty
          ? _channels
          : _channels
                .where(
                  (c) => (c['name'] ?? '').toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = provider.liveCategories;
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
                      onChanged: _filterChannels,
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
                            _filterChannels('');
                            setState(() => _showSearch = false);
                          },
                        ),
                        hintText: isAr
                            ? 'بحث عن قناة...'
                            : 'Search channels...',
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
                          isAr ? 'القنوات' : 'Channels',
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

        // Channels Grid
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _filteredChannels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.live_tv,
                        size: 60,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isAr ? 'لا توجد قنوات' : 'No channels found',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filteredChannels.length,
                  itemBuilder: (ctx, i) =>
                      _buildChannelCard(_filteredChannels[i], i),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, String? id, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () => _loadChannels(id),
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

  Widget _buildChannelCard(Map<String, dynamic> channel, int index) {
    final name = channel['name'] ?? '';
    final logo = channel['stream_icon'] ?? '';
    final streamId = channel['stream_id']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        final url = context.read<AppProvider>().xtream.getLiveStreamUrl(
          streamId,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(title: name, url: url, isLive: true),
          ),
        );
      },
      child:
          Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: logo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: logo,
                              width: 55,
                              height: 55,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => _buildLogoPlaceholder(),
                              errorWidget: (_, __, ___) =>
                                  _buildLogoPlaceholder(),
                            )
                          : _buildLogoPlaceholder(),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * (index % 12)))
              .scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.tv, color: AppColors.textMuted, size: 25),
    );
  }
}
