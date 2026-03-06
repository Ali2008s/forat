// ═══════════════════════════════════════════════════════════════
//  ForaTV - Live TV Screen
//  Categories popup button + Channel grid (full-image) + Search
//  ★ Full D-Pad / TV Remote support
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';
import '../services/favorites_service.dart';
import 'player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});
  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  List<dynamic> _allChannels = [];
  List<dynamic> _filteredChannels = [];
  String? _selectedCategory;
  String _selectedCategoryName = '';
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

  Future<void> _loadChannels([String? categoryId, String? categoryName]) async {
    final provider = context.read<AppProvider>();

    setState(() {
      _selectedCategory = categoryId;
      _selectedCategoryName = categoryName ?? '';
      _searchCtrl.clear();
    });

    if (_allChannels.isEmpty) {
      if (mounted) setState(() => _isLoading = true);
      _allChannels = await provider.xtream.getLiveStreams();
      if (mounted) setState(() => _isLoading = false);
    }

    setState(() {
      if (categoryId == null) {
        _filteredChannels = _allChannels;
      } else {
        _filteredChannels = _allChannels
            .where((c) => c['category_id'].toString() == categoryId)
            .toList();
      }
    });
  }

  void _filterChannels(String query) {
    setState(() {
      final baseList = _selectedCategory == null
          ? _allChannels
          : _allChannels
                .where((c) => c['category_id'].toString() == _selectedCategory)
                .toList();

      _filteredChannels = query.isEmpty
          ? baseList
          : baseList
                .where(
                  (c) => (c['name'] ?? '').toString().toLowerCase().contains(
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
      builder: (_) => _CategoriesSheet(
        categories: categories,
        selectedId: _selectedCategory,
        isAr: isAr,
        onSelect: (id, name) {
          Navigator.pop(context);
          _loadChannels(id, name);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final categories = provider.liveCategories;
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
                      onChanged: _filterChannels,
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
                            _filterChannels('');
                            setState(() => _showSearch = false);
                          },
                        ),
                        hintText: isAr
                            ? 'بحث عن قناة...'
                            : 'Search channels...',
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
                              isAr ? 'البث المباشر' : 'Live TV',
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
                                  Iconsax.filter_edit,
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
                            Iconsax.search_normal_1,
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

        // Channels Count
        if (!_showSearch && !_isLoading && _filteredChannels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                '${_filteredChannels.length} ${isAr ? "قناة" : "channels"}',
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
                        Iconsax.play_circle,
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
              : FocusTraversalGroup(
                  policy: ReadingOrderTraversalPolicy(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _filteredChannels.length,
                    itemBuilder: (ctx, i) =>
                        _buildChannelCard(_filteredChannels[i], i),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildChannelCard(Map<String, dynamic> channel, int index) {
    final name = channel['name'] ?? '';
    final logo = channel['stream_icon'] ?? '';
    final streamId = channel['stream_id']?.toString() ?? '';

    return TVFocusable(
      autofocus: index == 0,
      borderRadius: 14,
      onSelect: () {
        final provider = context.read<AppProvider>();
        final url = provider.xtream.getLiveStreamUrl(streamId);

        final channelList = _filteredChannels.map<Map<String, dynamic>>((c) {
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
              currentChannelIndex: index,
            ),
          ),
        );
      },
      onLongPress: () async {
        final provider = context.read<AppProvider>();
        final isAr = provider.locale == 'ar';
        final isFav = await FavoritesService.isChannelFavorite(streamId);
        if (isFav) {
          await FavoritesService.removeFavoriteChannel(streamId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAr ? 'تمت الإزالة من المفضلة' : 'Removed from favorites',
                ),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          await FavoritesService.addFavoriteChannel(channel);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAr ? 'تمت الإضافة إلى المفضلة ❤' : 'Added to favorites ❤',
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      },
      child:
          Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder, width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    logo.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: logo,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildLogoPlaceholder(),
                            errorWidget: (_, __, ___) =>
                                _buildLogoPlaceholder(),
                          )
                        : _buildLogoPlaceholder(),
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
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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
                            Icon(Iconsax.record, color: Colors.white, size: 6),
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
              .fadeIn(delay: Duration(milliseconds: 40 * (index % 12)))
              .scale(begin: const Offset(0.92, 0.92)),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Iconsax.play_circle, color: AppColors.textMuted, size: 30),
      ),
    );
  }
}

// ─── Categories Bottom Sheet ─────────────────────────────────────
class _CategoriesSheet extends StatefulWidget {
  final List<dynamic> categories;
  final String? selectedId;
  final bool isAr;
  final void Function(String? id, String name) onSelect;

  const _CategoriesSheet({
    required this.categories,
    required this.selectedId,
    required this.isAr,
    required this.onSelect,
  });

  @override
  State<_CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends State<_CategoriesSheet> {
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
            // Handle
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
                      isAr ? 'اختر القسم' : 'Select Category',
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
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.glassBg
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.glassBorder
                        : Colors.grey.shade200,
                  ),
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
            // List
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _filtered.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    // All option
                    final isSelected = widget.selectedId == null;
                    return _buildCatItem(
                      name: isAr ? '📺 الكل' : '📺 All',
                      id: null,
                      isSelected: isSelected,
                      count: '',
                      isAr: isAr,
                    );
                  }
                  final cat = _filtered[i - 1];
                  final id = cat['category_id']?.toString();
                  final isSelected = widget.selectedId == id;
                  return _buildCatItem(
                    name: cat['category_name'] ?? '',
                    id: id,
                    isSelected: isSelected,
                    count: '',
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

  Widget _buildCatItem({
    required String name,
    required String? id,
    required bool isSelected,
    required String count,
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
          border: Border(
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
