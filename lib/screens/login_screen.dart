// ═══════════════════════════════════════════════════════════════
//  ForaTV - Login Screen
//  Server dropdown + optional host + language selector
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _customHostCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _useCustomHost = false;
  String? _error;
  String? _selectedServerId;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _customHostCtrl.dispose();
    super.dispose();
  }

  String _getServerHost() {
    if (_useCustomHost && _customHostCtrl.text.trim().isNotEmpty) {
      return _customHostCtrl.text.trim();
    }
    final provider = context.read<AppProvider>();
    final server = provider.serversList.firstWhere(
      (s) => s['id'] == _selectedServerId,
      orElse: () => {},
    );
    if (server.isEmpty) return '';
    final host = server['host'] ?? '';
    final port = server['port'] ?? '';
    return port.isNotEmpty ? 'http://$host:$port' : host;
  }

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final provider = context.read<AppProvider>();
    final isAr = provider.locale == 'ar';
    final serverHost = _getServerHost();

    if (username.isEmpty || password.isEmpty) {
      setState(
        () => _error = isAr ? 'يرجى ملء جميع الحقول' : 'Please fill all fields',
      );
      return;
    }
    if (serverHost.isEmpty) {
      setState(
        () => _error = isAr
            ? 'يرجى اختيار سيرفر أو إدخال رابط'
            : 'Please select a server or enter a URL',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await provider.login(username, password, serverHost);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() {
        _isLoading = false;
        _error = result['error'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isAr = provider.locale == 'ar';

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Language Selector (top-left)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
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
                              iconEnabledColor: AppColors.textSecondary,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'ar',
                                  child: Text(
                                    '🇮🇶 عربي',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(
                                    '🇬🇧 English',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) provider.setLocale(v);
                              },
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 20),

                      // Logo
                      Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.satellite_alt,
                              size: 45,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.7, 0.7)),

                      const SizedBox(height: 18),
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 4),
                      Text(
                        isAr ? 'تسجيل الدخول' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 30),

                      // Error
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().shake(),

                      // Server Dropdown from Admin
                      if (provider.serversList.isNotEmpty && !_useCustomHost)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedServerId,
                              isExpanded: true,
                              dropdownColor: AppColors.bgCard,
                              iconEnabledColor: AppColors.textMuted,
                              hint: Row(
                                children: [
                                  const Icon(
                                    Icons.dns_outlined,
                                    color: AppColors.textMuted,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isAr ? 'اختر السيرفر' : 'Select Server',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              items: provider.serversList
                                  .map(
                                    (s) => DropdownMenuItem<String>(
                                      value: s['id'],
                                      child: Text(
                                        s['name'] ?? '',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedServerId = v),
                            ),
                          ),
                        ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1),

                      if (provider.serversList.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        // Custom Host Toggle
                        GestureDetector(
                          onTap: () => setState(() {
                            _useCustomHost = !_useCustomHost;
                          }),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _useCustomHost
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isAr
                                    ? 'لدي سيرفر خاص'
                                    : 'I have a custom server',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 380.ms),
                        const SizedBox(height: 10),
                      ],

                      // Custom Host Field
                      if (_useCustomHost || provider.serversList.isEmpty)
                        _buildTextField(
                          controller: _customHostCtrl,
                          icon: Icons.dns_outlined,
                          hint: isAr
                              ? 'رابط السيرفر (Host)'
                              : 'Server URL (Host)',
                          textDirection: TextDirection.ltr,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                      const SizedBox(height: 14),

                      // Username
                      _buildTextField(
                        controller: _usernameCtrl,
                        icon: Icons.person_outline,
                        hint: isAr ? 'اسم المستخدم' : 'Username',
                        textDirection: TextDirection.ltr,
                      ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1),

                      const SizedBox(height: 14),

                      // Password
                      _buildTextField(
                        controller: _passwordCtrl,
                        icon: Icons.lock_outline,
                        hint: isAr ? 'كلمة المرور' : 'Password',
                        textDirection: TextDirection.ltr,
                        obscure: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                      const SizedBox(height: 26),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isAr ? 'تسجيل الدخول' : 'Sign In',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                      const SizedBox(height: 25),

                      // Support Links
                      if (provider.telegramLink.isNotEmpty ||
                          provider.whatsappLink.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAr ? 'تحتاج مساعدة؟ ' : 'Need help? ',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            if (provider.telegramLink.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => launchUrl(
                                  Uri.parse(provider.telegramLink),
                                  mode: LaunchMode.externalApplication,
                                ),
                                icon: const Icon(
                                  Icons.telegram,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                label: Text(
                                  isAr ? 'تيليجرام' : 'Telegram',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            if (provider.whatsappLink.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => launchUrl(
                                  Uri.parse(provider.whatsappLink),
                                  mode: LaunchMode.externalApplication,
                                ),
                                icon: const Icon(
                                  Icons.chat,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                label: Text(
                                  isAr ? 'واتساب' : 'WhatsApp',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                          ],
                        ).animate().fadeIn(delay: 700.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextDirection? textDirection,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textDirection: textDirection,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 22),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
