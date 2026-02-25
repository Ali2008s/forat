// ═══════════════════════════════════════════════════════════════
//  ForaTV - Home Screen with Bottom Navigation
//  Live TV, Movies, Series, Settings tabs + notification + update
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
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

  void _showUpdateDialog(AppProvider provider) {
    if (_updateDialogShown) return;
    _updateDialogShown = true;
    final isAr = provider.locale == 'ar';

    showDialog(
      context: context,
      barrierDismissible: !provider.forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !provider.forceUpdate,
        child: Dialog(
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
                    Icons.system_update,
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
                  style: const TextStyle(color: AppColors.accent, fontSize: 14),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (provider.apkLink.isNotEmpty) {
                        launchUrl(
                          Uri.parse(provider.apkLink),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Text(isAr ? 'تحديث الآن' : 'Update Now'),
                  ),
                ),
                if (!provider.forceUpdate) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      isAr ? 'لاحقاً' : 'Later',
                      style: const TextStyle(color: AppColors.textMuted),
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
        ),
      ),
    );
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

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: provider.isDarkMode ? AppColors.bgGradient : null,
              color: provider.isDarkMode ? null : AppColors.bgLightPrimary,
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
                            Icons.campaign,
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
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      provider.notificationEnabled ? 5 : 15,
                      16,
                      10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isAr ? "مرحباً" : "Welcome"}, ${provider.clientName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                isAr
                                    ? 'ماذا تريد أن تشاهد اليوم؟'
                                    : 'What do you want to watch?',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
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
                Expanded(child: _pages[_currentIndex]),
              ],
            ),
          ),

          // Bottom Navigation (4 tabs)
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: provider.isDarkMode ? AppColors.bgCard : Colors.white,
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
                  icon: const Icon(Icons.live_tv),
                  label: isAr ? 'بث مباشر' : 'Live TV',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.movie_outlined),
                  label: isAr ? 'أفلام' : 'Movies',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.tv),
                  label: isAr ? 'مسلسلات' : 'Series',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  label: isAr ? 'إعدادات' : 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
