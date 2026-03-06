// ═══════════════════════════════════════════════════════════════
//  ForaTV - Home Screen with Bottom Navigation
//  Live TV, Movies, Series, Settings tabs + notification + update
//  ★ Full D-Pad / TV Remote support
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';
import 'live_tv_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _updateDialogShown = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  StateSetter? _setDialogState;

  final List<Widget> _pages = const [
    LiveTvScreen(),
    MoviesScreen(),
    SeriesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadCategories();
    });
  }

  Future<void> _downloadAndInstallApk(String url, AppProvider provider) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dio = Dio(
        BaseOptions(
          followRedirects: true,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 10),
          headers: {"Accept-Encoding": "identity", "Connection": "Keep-Alive"},
        ),
      );

      final extDir = await getExternalStorageDirectory();
      if (extDir == null) throw "لا يمكن الوصول لذاكرة التخزين";

      final savePath = "${extDir.path}/update.apk";
      final file = File(savePath);

      if (await file.exists()) {
        await file.delete();
      }

      await dio.download(
        url,
        savePath,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            if (mounted) {
              setState(() {
                _downloadProgress = progress;
              });
              _setDialogState?.call(() {});
            }
          }
        },
      );

      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint("Download completed. File size: $fileSize bytes");

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اكتمل التحميل، جاري فتح المثبت...')),
          );
        }

        final result = await OpenFilex.open(
          savePath,
          type: "application/vnd.android.package-archive",
        );

        if (result.type != ResultType.done) {
          throw "خطأ في فتح الملف: ${result.message}";
        }

        if (mounted && !provider.forceUpdate) {
          Navigator.pop(context);
        }
      } else {
        throw "فشل تحميل الملف - غير موجود";
      }
    } catch (e) {
      debugPrint("Update Error: $e");
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains("Direct link")) {
          errorMsg =
              "تأكد من وضع رابط تحميل مباشر للملف في لوحة التحكم (رابط ينتهي بـ .apk)";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _showUpdateDialog(AppProvider provider) {
    if (_updateDialogShown) return;
    _updateDialogShown = true;
    final isAr = provider.locale == 'ar';

    showDialog(
      context: context,
      barrierDismissible: !provider.forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !provider.forceUpdate,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            _setDialogState = setModalState;
            return Dialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.glassBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Iconsax.cloud_change,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isAr ? 'تحديث جديد متوفر!' : 'New Update Available!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${isAr ? "الإصدار" : "Version"} ${provider.latestVersion}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (provider.updateNotes.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.glassBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'ما الجديد:' : "What's new:",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.updateNotes,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_isDownloading) ...[
                      LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${(_downloadProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: TVFocusable(
                          autofocus: true,
                          onSelect: () {
                            if (provider.apkLink.isNotEmpty) {
                              _downloadAndInstallApk(
                                provider.apkLink,
                                provider,
                              );
                            }
                          },
                          child: ElevatedButton(
                            onPressed: () {
                              if (provider.apkLink.isNotEmpty) {
                                _downloadAndInstallApk(
                                  provider.apkLink,
                                  provider,
                                );
                              }
                            },
                            child: Text(isAr ? 'تحديث الآن' : 'Update Now'),
                          ),
                        ),
                      ),
                    if (!provider.forceUpdate && !_isDownloading) ...[
                      const SizedBox(height: 8),
                      TVFocusable(
                        onSelect: () => Navigator.pop(ctx),
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            isAr ? 'لاحقاً' : 'Later',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ],
                    if (provider.forceUpdate)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          isAr
                              ? 'هذا التحديث إجباري ولا يمكن تخطيه'
                              : 'This update is mandatory',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.danger.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).then((_) {
      _setDialogState = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isAr = provider.locale == 'ar';

        if (provider.hasUpdate && !_updateDialogShown) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showUpdateDialog(provider),
          );
        }

        return TVRemoteHandler(
          child: Shortcuts(
            shortcuts: <ShortcutActivator, Intent>{
              // Number keys to switch tabs quickly
              const SingleActivator(LogicalKeyboardKey.digit1):
                  const _SwitchTabIntent(0),
              const SingleActivator(LogicalKeyboardKey.digit2):
                  const _SwitchTabIntent(1),
              const SingleActivator(LogicalKeyboardKey.digit3):
                  const _SwitchTabIntent(2),
              const SingleActivator(LogicalKeyboardKey.digit4):
                  const _SwitchTabIntent(3),
            },
            child: Actions(
              actions: {
                _SwitchTabIntent: CallbackAction<_SwitchTabIntent>(
                  onInvoke: (intent) {
                    setState(() => _currentIndex = intent.tabIndex);
                    return null;
                  },
                ),
              },
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    gradient: provider.isDarkMode ? AppColors.bgGradient : null,
                    color: provider.isDarkMode
                        ? null
                        : AppColors.bgLightPrimary,
                  ),
                  child: Column(
                    children: [
                      // Notification Bar
                      if (provider.notificationEnabled &&
                          provider.notificationBar.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.2),
                                AppColors.accent.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.notification_bing,
                                  color: AppColors.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    provider.notificationBar,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: -1),

                      // App Bar
                      if (_currentIndex <= 3)
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              provider.notificationEnabled ? 5 : 20,
                              20,
                              15,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${isAr ? "مرحباً" : "Welcome back"}, ${provider.clientName}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.titleLarge?.color,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Tabs Content
                      Expanded(
                        child: FocusTraversalGroup(
                          policy: ReadingOrderTraversalPolicy(),
                          child: IndexedStack(
                            index: _currentIndex,
                            children: _pages,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Navigation with D-Pad support
                bottomNavigationBar: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        if (_currentIndex > 0) {
                          setState(() => _currentIndex--);
                          return KeyEventResult.handled;
                        }
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowRight) {
                        if (_currentIndex < 3) {
                          setState(() => _currentIndex++);
                          return KeyEventResult.handled;
                        }
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? AppColors.bgCard
                          : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: provider.isDarkMode
                              ? AppColors.glassBorder
                              : Colors.grey.shade200,
                        ),
                      ),
                      boxShadow: provider.isDarkMode
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (i) => setState(() => _currentIndex = i),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: AppColors.textMuted,
                      type: BottomNavigationBarType.fixed,
                      selectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      unselectedLabelStyle: const TextStyle(fontSize: 10),
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Iconsax.play_circle),
                          activeIcon: const Icon(
                            Iconsax.play_circle,
                            color: AppColors.primary,
                          ),
                          label: isAr ? 'بث مباشر' : 'Live TV',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Iconsax.video_horizontal),
                          activeIcon: const Icon(
                            Iconsax.video_horizontal,
                            color: AppColors.primary,
                          ),
                          label: isAr ? 'أفلام' : 'Movies',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Iconsax.video_play),
                          activeIcon: const Icon(
                            Iconsax.video_play,
                            color: AppColors.primary,
                          ),
                          label: isAr ? 'مسلسلات' : 'Series',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Iconsax.setting_2),
                          activeIcon: const Icon(
                            Iconsax.setting_2,
                            color: AppColors.primary,
                          ),
                          label: isAr ? 'الإعدادات' : 'Settings',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Intent for switching tabs via keyboard shortcuts
class _SwitchTabIntent extends Intent {
  final int tabIndex;
  const _SwitchTabIntent(this.tabIndex);
}
