// ═══════════════════════════════════════════════════════════════
//  ForaTV - Settings Screen
//  Player type, server info, dark/light mode, account details
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'login_screen.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Info Card
              _buildSectionTitle(
                isAr ? 'معلومات الحساب' : 'Account Info',
                Icons.person_outline,
                0,
              ),
              const SizedBox(height: 10),
              _buildCard(context, [
                _buildInfoRow(
                  isAr ? 'اسم المستخدم' : 'Username',
                  provider.username,
                  Icons.person,
                ),
                _buildInfoRow(
                  isAr ? 'كلمة المرور' : 'Password',
                  '••••••••',
                  Icons.lock,
                ),
                _buildInfoRow(
                  isAr ? 'الحالة' : 'Status',
                  status.toString(),
                  Icons.verified_user,
                  valueColor: status == 'Active'
                      ? AppColors.success
                      : AppColors.warning,
                ),
                _buildInfoRow(
                  isAr ? 'أقصى اتصالات' : 'Max Connections',
                  maxCon.toString(),
                  Icons.devices,
                ),
              ], 1),

              const SizedBox(height: 20),

              // Server Info Card
              _buildSectionTitle(
                isAr ? 'معلومات السيرفر' : 'Server Info',
                Icons.dns_outlined,
                2,
              ),
              const SizedBox(height: 10),
              _buildCard(context, [
                _buildInfoRow(
                  isAr ? 'رابط السيرفر' : 'Server URL',
                  provider.serverHost,
                  Icons.link,
                ),
                _buildInfoRow(
                  isAr ? 'تاريخ الإنشاء' : 'Created At',
                  createdFormatted,
                  Icons.calendar_today,
                ),
                _buildInfoRow(
                  isAr ? 'تاريخ الانتهاء' : 'Expiry Date',
                  expiryFormatted,
                  Icons.event_busy,
                  valueColor: AppColors.warning,
                ),
              ], 3),

              const SizedBox(height: 20),

              // App Settings Card
              _buildSectionTitle(
                isAr ? 'إعدادات التطبيق' : 'App Settings',
                Icons.settings_outlined,
                4,
              ),
              const SizedBox(height: 10),
              _buildCard(context, [
                // Dark/Light Mode Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        provider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
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
                const Divider(height: 1, color: AppColors.glassBorder),
                // Language
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.language,
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
                            dropdownColor: AppColors.bgCard,
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
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

              // App Info
              _buildSectionTitle(
                isAr ? 'عن التطبيق' : 'About',
                Icons.info_outline,
                6,
              ),
              const SizedBox(height: 10),
              _buildCard(context, [
                _buildInfoRow(
                  isAr ? 'اسم التطبيق' : 'App Name',
                  AppConstants.appName,
                  Icons.apps,
                ),
                _buildInfoRow(
                  isAr ? 'الإصدار' : 'Version',
                  AppConstants.appVersion,
                  Icons.code,
                ),
              ], 7),

              const SizedBox(height: 25),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await provider.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.exit_to_app, size: 20),
                  label: Text(
                    isAr ? 'تسجيل الخروج' : 'Logout',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, int index) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildCard(BuildContext context, List<Widget> children, int index) {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(children: children),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.05);
  }

  Widget _buildInfoRow(
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
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textPrimary,
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
