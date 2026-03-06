import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../providers/app_provider.dart';
import '../providers/download_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final downloadProvider = context.watch<DownloadProvider>();
    final isAr = provider.locale == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: provider.isDarkMode ? AppColors.bgGradient : null,
          color: provider.isDarkMode ? null : AppColors.bgLightPrimary,
        ),
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Modern Header
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
                              isAr ? 'التنزيلات' : 'Downloads',
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
                                  ? 'شاهد محتواك حتى بدون انترنت'
                                  : 'Watch your content offline anytime',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.document_download,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                            const Icon(Iconsax.document_download, size: 16),
                            const SizedBox(width: 6),
                            Text(isAr ? 'قيد التحميل' : 'Downloading'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.tick_circle, size: 16),
                            const SizedBox(width: 6),
                            Text(isAr ? 'المكتملة' : 'Completed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTaskList(
                        context,
                        downloadProvider.activeTasks,
                        isAr,
                        true,
                        provider,
                      ),
                      _buildTaskList(
                        context,
                        downloadProvider.completedTasks,
                        isAr,
                        false,
                        provider,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<DownloadTask> tasks,
    bool isAr,
    bool isActive,
    AppProvider provider,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Iconsax.document_download : Iconsax.tick_circle,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isAr ? 'لا يوجد تنزيلات هنا' : 'No downloads here',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskItem(context, task, isAr, isActive, provider);
        },
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    DownloadTask task,
    bool isAr,
    bool isActive,
    AppProvider provider,
  ) {
    final downloadProvider = context.read<DownloadProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: provider.isDarkMode
              ? AppColors.glassBorder
              : Colors.grey.shade200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover
              SizedBox(
                width: 70,
                child: task.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: task.coverUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _buildFallbackIcon(task.type),
                      )
                    : _buildFallbackIcon(task.type),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: provider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isActive) ...[
                        if (task.status == DownloadStatus.downloading) ...[
                          LinearProgressIndicator(
                            value: task.progress,
                            backgroundColor: provider.isDarkMode
                                ? Colors.white10
                                : Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(task.progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ] else if (task.status == DownloadStatus.failed) ...[
                          Text(
                            isAr ? 'فشل التحميل ⚠' : 'Download Failed ⚠',
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else if (task.status == DownloadStatus.canceled) ...[
                          Text(
                            isAr ? 'تم الإلغاء ✕' : 'Canceled ✕',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          isAr ? 'مكتمل ✓' : 'Completed ✓',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Actions
              Row(
                children: [
                  if (!isActive)
                    TVFocusable(
                      borderRadius: 20,
                      onSelect: () => downloadProvider.openFile(task.savePath),
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.play_circle,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            downloadProvider.openFile(task.savePath),
                      ),
                    ),
                  if (isActive &&
                      (task.status == DownloadStatus.failed ||
                          task.status == DownloadStatus.canceled))
                    TVFocusable(
                      borderRadius: 20,
                      onSelect: () {
                        downloadProvider.startDownload(
                          id: task.id,
                          title: task.title,
                          type: task.type,
                          coverUrl: task.coverUrl,
                          url: task.url,
                          ext: task.savePath.split('.').last,
                          seriesFolder: task.type == 'series'
                              ? task.savePath.split('/').reversed.elementAt(1)
                              : null,
                        );
                      },
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.refresh,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          downloadProvider.startDownload(
                            id: task.id,
                            title: task.title,
                            type: task.type,
                            coverUrl: task.coverUrl,
                            url: task.url,
                            ext: task.savePath.split('.').last,
                            seriesFolder: task.type == 'series'
                                ? task.savePath.split('/').reversed.elementAt(1)
                                : null,
                          );
                        },
                      ),
                    ),
                  TVFocusable(
                    borderRadius: 20,
                    focusColor: AppColors.danger,
                    onSelect: () {
                      if (isActive &&
                          task.status == DownloadStatus.downloading) {
                        downloadProvider.cancelDownload(task.id);
                      } else {
                        _showDeleteConfirm(context, task, isAr, provider);
                      }
                    },
                    child: IconButton(
                      icon: Icon(
                        isActive
                            ? (task.status == DownloadStatus.downloading
                                  ? Iconsax.close_circle
                                  : Iconsax.trash)
                            : Iconsax.trash,
                        color:
                            isActive &&
                                task.status == DownloadStatus.downloading
                            ? AppColors.textMuted
                            : AppColors.danger,
                      ),
                      onPressed: () {
                        if (isActive &&
                            task.status == DownloadStatus.downloading) {
                          downloadProvider.cancelDownload(task.id);
                        } else {
                          _showDeleteConfirm(context, task, isAr, provider);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(begin: 0.1).fadeIn();
  }

  Widget _buildFallbackIcon(String type) {
    return Container(
      color: AppColors.surface,
      child: Icon(
        type == 'movie' ? Iconsax.video : Iconsax.video_play,
        color: AppColors.textMuted,
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    DownloadTask task,
    bool isAr,
    AppProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(
          isAr ? 'حذف التنزيل؟' : 'Delete download?',
          style: TextStyle(
            color: provider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد من حذف "${task.title}"؟ سيتم حذف الملف من جهازك.'
              : 'Are you sure you want to delete "${task.title}"? The file will be removed from your device.',
        ),
        actions: [
          TVFocusable(
            borderRadius: 8,
            onSelect: () => Navigator.pop(ctx),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
          ),
          TVFocusable(
            borderRadius: 8,
            focusColor: AppColors.danger,
            onSelect: () {
              context.read<DownloadProvider>().removeTask(task.id);
              Navigator.pop(ctx);
            },
            child: TextButton(
              onPressed: () {
                context.read<DownloadProvider>().removeTask(task.id);
                Navigator.pop(ctx);
              },
              child: Text(
                isAr ? 'حذف' : 'Delete',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
