// ═══════════════════════════════════════════════════════════════
//  ForaTV - Settings Screen
//  Player type, server info, dark/light mode, account details
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'downloads_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isAr = provider.locale == 'ar';
        final userInfo = provider.userInfo ?? {};
        final expDate = userInfo['exp_date'] ?? '';
        final maxCon = userInfo['max_connections'] ?? '';
        final createdAt = userInfo['created_at'] ?? '';
        final status = userInfo['status'] ?? '';

        // Format expiry
        String expiryFormatted = '--';
        if (expDate != null && expDate.toString().isNotEmpty) {
          try {
            final ts = int.tryParse(expDate.toString());
            if (ts != null) {
              expiryFormatted = DateTime.fromMillisecondsSinceEpoch(
                ts * 1000,
              ).toString().substring(0, 10);
            } else {
              expiryFormatted = expDate.toString();
            }
          } catch (_) {
            expiryFormatted = expDate.toString();
          }
        }

        String createdFormatted = '--';
        if (createdAt != null && createdAt.toString().isNotEmpty) {
          try {
            final ts = int.tryParse(createdAt.toString());
            if (ts != null) {
              createdFormatted = DateTime.fromMillisecondsSinceEpoch(
                ts * 1000,
              ).toString().substring(0, 10);
            }
          } catch (_) {}
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Internal Header removed as per user request to avoid jumping and redundancy

                // Account Info Card
                _buildSectionTitle(
                  context,
                  isAr ? 'معلومات الحساب' : 'Account Info',
                  Iconsax.user,
                  0,
                ),
                const SizedBox(height: 10),
                _buildCard(context, [
                  _buildInfoRow(
                    context,
                    isAr ? 'اسم المستخدم' : 'Username',
                    provider.username,
                    Iconsax.user,
                  ),
                  _buildInfoRow(
                    context,
                    isAr ? 'كلمة المرور' : 'Password',
                    '••••••••',
                    Iconsax.lock,
                  ),
                  _buildInfoRow(
                    context,
                    isAr ? 'الحالة' : 'Status',
                    status.toString(),
                    Iconsax.verify,
                    valueColor: status == 'Active'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  _buildInfoRow(
                    context,
                    isAr ? 'أقصى اتصالات' : 'Max Connections',
                    maxCon.toString(),
                    Iconsax.hierarchy,
                  ),
                ], 1),

                const SizedBox(height: 20),

                // Server Info Card
                _buildSectionTitle(
                  context,
                  isAr ? 'معلومات السيرفر' : 'Server Info',
                  Iconsax.status,
                  2,
                ),
                const SizedBox(height: 10),
                _buildCard(context, [
                  _buildInfoRow(
                    context,
                    isAr ? 'رابط السيرفر' : 'Server URL',
                    provider.serverHost,
                    Iconsax.link,
                  ),
                  _buildInfoRow(
                    context,
                    isAr ? 'تاريخ الإنشاء' : 'Created At',
                    createdFormatted,
                    Iconsax.calendar,
                  ),
                  _buildInfoRow(
                    context,
                    isAr ? 'تاريخ الانتهاء' : 'Expiry Date',
                    expiryFormatted,
                    Iconsax.calendar_remove,
                    valueColor: AppColors.warning,
                  ),
                ], 3),

                const SizedBox(height: 20),

                // App Settings Card
                _buildSectionTitle(
                  context,
                  isAr ? 'إعدادات التطبيق' : 'App Settings',
                  Iconsax.setting_2,
                  4,
                ),
                const SizedBox(height: 10),
                _buildCard(context, [
                  // Dark/Light Mode Toggle
                  TVFocusable(
                    borderRadius: 0,
                    onSelect: () => provider.toggleTheme(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                            color: AppColors.accent,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              isAr ? 'الوضع الداكن' : 'Dark Mode',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch(
                            value: provider.isDarkMode,
                            onChanged: (_) => provider.toggleTheme(),
                            activeTrackColor: AppColors.primary.withValues(
                              alpha: 0.5,
                            ),
                            thumbColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: provider.isDarkMode
                        ? AppColors.glassBorder
                        : Colors.grey.shade200,
                  ),
                  // Language
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.global,
                          color: AppColors.cyan,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            isAr ? 'اللغة' : 'Language',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: provider.locale,
                              dropdownColor: Theme.of(context).cardTheme.color,
                              isDense: true,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ar',
                                  child: Text('عربي'),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) provider.setLocale(v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ], 5),

                const SizedBox(height: 20),

                // Downloads Button
                TVFocusable(
                  borderRadius: 16,
                  focusColor: AppColors.primary,
                  onSelect: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DownloadsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Iconsax.document_download,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'التنزيلات' : 'Downloads',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr
                                    ? 'إدارة الأفلام والمسلسلات المحملة'
                                    : 'Manage your downloaded content',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                // Favorites Button
                TVFocusable(
                  borderRadius: 16,
                  focusColor: AppColors.neonPink,
                  onSelect: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPink.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Iconsax.heart,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'المفضلة' : 'Favorites',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr
                                    ? 'أفلامك ومسلسلاتك وقنواتك المفضلة'
                                    : 'Your favorite movies, series & channels',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                // App Info
                _buildSectionTitle(
                  context,
                  isAr ? 'عن التطبيق' : 'About',
                  Iconsax.info_circle,
                  6,
                ),
                const SizedBox(height: 10),
                _buildCard(context, [
                  _buildInfoRow(
                    context,
                    isAr ? 'اسم التطبيق' : 'App Name',
                    AppConstants.appName,
                    Iconsax.category,
                  ),
                  _buildInfoRow(
                    context,
                    isAr ? 'الإصدار' : 'Version',
                    AppConstants.appVersion,
                    Iconsax.code,
                  ),
                ], 7),

                const SizedBox(height: 25),

                // Logout Button
                TVFocusable(
                  borderRadius: 14,
                  focusColor: AppColors.danger,
                  onSelect: () async {
                    await provider.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await provider.logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.logout, size: 20),
                      label: Text(
                        isAr ? 'تسجيل الخروج' : 'Logout',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    int index,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildCard(BuildContext context, List<Widget> children, int index) {
    return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.glassBorder
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(children: children),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.05);
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}
