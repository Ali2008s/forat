// ═══════════════════════════════════════════════════════════════
//  ForaTV - Live TV Screen
//  Categories + Channel grid with glassmorphism cards
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
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels([String? categoryId]) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = categoryId;
    });
    final provider = context.read<AppProvider>();
    _channels = await provider.xtream.getLiveStreams(categoryId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().liveCategories;

    return Column(
      children: [
        // Categories Chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return _buildCategoryChip(
                  'الكل',
                  null,
                  _selectedCategory == null,
                );
              }
              final cat = categories[i - 1];
              return _buildCategoryChip(
                cat['category_name'] ?? '',
                cat['category_id']?.toString(),
                _selectedCategory == cat['category_id']?.toString(),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Channels Grid
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _channels.isEmpty
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
                      const Text(
                        'لا توجد قنوات',
                        style: TextStyle(
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
                  itemCount: _channels.length,
                  itemBuilder: (ctx, i) => _buildChannelCard(_channels[i], i),
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
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: logo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: logo,
                              width: 55,
                              height: 55,
                              fit: BoxFit.contain,
                              placeholder: (_, __) => Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: AppColors.glassBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tv,
                                  color: AppColors.textMuted,
                                  size: 25,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: AppColors.glassBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tv,
                                  color: AppColors.textMuted,
                                  size: 25,
                                ),
                              ),
                            )
                          : Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: AppColors.glassBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.tv,
                                color: AppColors.textMuted,
                                size: 25,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    // Name
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
}
