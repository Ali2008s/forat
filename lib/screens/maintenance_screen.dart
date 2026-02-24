// ═══════════════════════════════════════════════════════════════
//  ForaTV - Maintenance / App Killed Screen
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';

class MaintenanceScreen extends StatelessWidget {
  final bool isKilled;
  final String message;

  const MaintenanceScreen({
    super.key,
    required this.isKilled,
    this.message = '',
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color:
                              (isKilled ? AppColors.danger : AppColors.warning)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          isKilled ? Icons.power_off : Icons.build_circle,
                          size: 50,
                          color: isKilled
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.6, 0.6)),

                  const SizedBox(height: 30),

                  Text(
                    isKilled ? 'التطبيق متوقف' : 'تحت الصيانة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isKilled ? AppColors.danger : AppColors.warning,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 15),

                  Text(
                    message.isNotEmpty
                        ? message
                        : (isKilled
                              ? 'التطبيق متوقف عن العمل حالياً.\nيرجى التواصل مع الدعم الفني.'
                              : 'نعتذر! التطبيق تحت الصيانة حالياً.\nسنعود قريباً إن شاء الله.'),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),

                  // Support Links
                  if (provider.telegramLink.isNotEmpty ||
                      provider.whatsappLink.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (provider.telegramLink.isNotEmpty)
                          _buildSupportBtn(
                            Icons.telegram,
                            'تيليجرام',
                            AppColors.info,
                            provider.telegramLink,
                          ),
                        const SizedBox(width: 15),
                        if (provider.whatsappLink.isNotEmpty)
                          _buildSupportBtn(
                            Icons.chat,
                            'واتساب',
                            AppColors.success,
                            provider.whatsappLink,
                          ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportBtn(
    IconData icon,
    String label,
    Color color,
    String url,
  ) {
    return OutlinedButton.icon(
      onPressed: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
