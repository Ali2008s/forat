// ═══════════════════════════════════════════════════════════════
//  ForaTV - Home Screen with Bottom Navigation
//  Live TV, Movies, Series tabs + notification bar + update dialog
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
import 'login_screen.dart';

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
  ];

  @override
  void initState() {
    super.initState();
    // Load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadCategories();
    });
  }

  void _showUpdateDialog(AppProvider provider) {
    if (_updateDialogShown) return;
    _updateDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: !provider.forceUpdate,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => !provider.forceUpdate,
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
                const Text(
                  'تحديث جديد متوفر!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'الإصدار ${provider.latestVersion}',
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
                        const Text(
                          'ما الجديد:',
                          style: TextStyle(
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
                    child: const Text('تحديث الآن'),
                  ),
                ),
                if (!provider.forceUpdate) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'لاحقاً',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ],
                if (provider.forceUpdate)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'هذا التحديث إجباري ولا يمكن تخطيه',
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
        // Check for updates
        if (provider.hasUpdate && !_updateDialogShown) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showUpdateDialog(provider),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
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
                        // Welcome
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً، ${provider.clientName}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Text(
                                'ماذا تريد أن تشاهد اليوم؟',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Logout
                        IconButton(
                          onPressed: () async {
                            await provider.logout();
                            if (!context.mounted) return;
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: AppColors.textMuted,
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

          // Bottom Navigation
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
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
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv),
                  label: 'بث مباشر',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined),
                  label: 'أفلام',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'مسلسلات'),
              ],
            ),
          ),
        );
      },
    );
  }
}
