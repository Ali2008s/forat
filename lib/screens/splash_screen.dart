// ═══════════════════════════════════════════════════════════════
//  ForaTV - Smart Splash Screen
//  Animated logo + silent Firebase sync + auto-login check
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'maintenance_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusKey =
      'loading'; // loading, connecting, checking_status, checking_login
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  String _getStatusText(bool isAr) {
    switch (_statusKey) {
      case 'connecting':
        return isAr ? 'جاري الاتصال بالسيرفر...' : 'Connecting to server...';
      case 'checking_status':
        return isAr ? 'فحص حالة التطبيق...' : 'Checking app status...';
      case 'checking_login':
        return isAr ? 'فحص بيانات الدخول...' : 'Checking login data...';
      default:
        return isAr ? 'جاري التهيئة...' : 'Initializing...';
    }
  }

  Future<void> _startInitialization() async {
    final provider = context.read<AppProvider>();

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _statusKey = 'connecting';
      _progress = 0.3;
    });
    await provider.initFirebase();
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _statusKey = 'checking_status';
      _progress = 0.5;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    if (provider.appKilled || provider.maintenanceMode) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MaintenanceScreen(
            isKilled: provider.appKilled,
            message: provider.maintenanceMessage,
          ),
        ),
      );
      return;
    }

    setState(() {
      _statusKey = 'checking_login';
      _progress = 0.7;
    });
    final autoLogin = await provider.tryAutoLogin();
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _statusKey = 'loading';
      _progress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    if (autoLogin) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isAr = provider.locale == 'ar';
        final isDark = provider.isDarkMode;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.bgGradient : null,
              color: isDark ? null : AppColors.bgLightPrimary,
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.satellite_alt,
                            size: 60,
                            color: Colors.white,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .then()
                        .shimmer(duration: 2000.ms, color: Colors.white24),

                    const SizedBox(height: 25),
                    // App Name
                    Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 3,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      isAr
                          ? 'بث مباشر | أفلام | مسلسلات'
                          : 'Live TV | Movies | Series',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                    const Spacer(flex: 2),
                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? AppColors.glassBorder
                                  : Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _getStatusText(isAr),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                        ],
                      ),
                    ).animate().fadeIn(delay: 900.ms, duration: 600.ms),

                    const SizedBox(height: 40),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ).animate().fadeIn(delay: 1000.ms),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
