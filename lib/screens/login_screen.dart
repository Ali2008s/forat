// ═══════════════════════════════════════════════════════════════
//  ForaTV - Login Screen
//  Server dropdown + optional host + language selector
//  ★ Full D-Pad / TV Remote support for all fields & buttons
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../utils/tv_focus_helper.dart';
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

  // Focus nodes for TV navigation
  final FocusNode _langFocusNode = FocusNode();
  final FocusNode _customHostToggleFocusNode = FocusNode();
  final FocusNode _serverDropdownFocusNode = FocusNode();
  final FocusNode _customHostFieldFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _loginBtnFocusNode = FocusNode();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _customHostCtrl.dispose();
    _langFocusNode.dispose();
    _customHostToggleFocusNode.dispose();
    _serverDropdownFocusNode.dispose();
    _customHostFieldFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginBtnFocusNode.dispose();
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
            ? 'يرجى اختيار سيرفر أو إدخال رابط السيرفر'
            : 'Please select a server or enter a URL',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final Map<String, dynamic> result;

    if (_useCustomHost || provider.serversList.isEmpty) {
      result = await provider.loginDirect(username, password, serverHost);
    } else {
      result = await provider.login(username, password, serverHost);
    }

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
                  padding: const EdgeInsets.all(24),
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Language Selector
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: TVFocusable(
                              focusNode: _langFocusNode,
                              autofocus: true,
                              borderRadius: 20,
                              onSelect: () {
                                // Toggle language on select
                                provider.setLocale(
                                  provider.locale == 'ar' ? 'en' : 'ar',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.glassBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                  ),
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
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: 32),

                        // Logo
                        Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Iconsax.monitor_recorder,
                                size: 44,
                                color: Colors.white,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.7, 0.7)),

                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: AppColors.textPrimary,
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

                        const SizedBox(height: 32),

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
                                  Iconsax.info_circle,
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

                        // Custom Server Toggle
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(2),
                          child: TVFocusable(
                            focusNode: _customHostToggleFocusNode,
                            borderRadius: 14,
                            onSelect: () => setState(() {
                              _useCustomHost = !_useCustomHost;
                              if (_useCustomHost) _selectedServerId = null;
                            }),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _useCustomHost
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : AppColors.glassBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _useCustomHost
                                      ? AppColors.primary.withValues(alpha: 0.5)
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _useCustomHost
                                        ? Iconsax.tick_square
                                        : Iconsax.record,
                                    color: _useCustomHost
                                        ? AppColors.accent
                                        : AppColors.textMuted,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isAr
                                              ? 'لدي سيرفر خاص'
                                              : 'I have a custom server',
                                          style: TextStyle(
                                            color: _useCustomHost
                                                ? AppColors.accent
                                                : AppColors.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_useCustomHost)
                                          Text(
                                            isAr
                                                ? 'أدخل رابط سيرفر الاكستريم الخاص بك'
                                                : 'Enter your Xtream server URL',
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Iconsax.hierarchy,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 340.ms),

                        const SizedBox(height: 12),

                        // Server Dropdown
                        if (provider.serversList.isNotEmpty &&
                            !_useCustomHost) ...[
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3),
                            child: TVFocusable(
                              focusNode: _serverDropdownFocusNode,
                              borderRadius: 14,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.glassBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                  ),
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
                                          Iconsax.hierarchy,
                                          color: AppColors.textMuted,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          isAr
                                              ? 'اختر السيرفر'
                                              : 'Select Server',
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
                              ),
                            ),
                          ).animate().fadeIn(delay: 380.ms).slideX(begin: 0.1),
                          const SizedBox(height: 12),
                        ],

                        // Custom Host Field
                        if (_useCustomHost || provider.serversList.isEmpty)
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(3),
                            child: _buildTextField(
                              controller: _customHostCtrl,
                              icon: Iconsax.link,
                              hint: isAr
                                  ? 'http://server.com:port'
                                  : 'http://server.com:port',
                              textDirection: TextDirection.ltr,
                              focusNode: _customHostFieldFocusNode,
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                        if (_useCustomHost || provider.serversList.isEmpty)
                          const SizedBox(height: 12),

                        // Username
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(4),
                          child: _buildTextField(
                            controller: _usernameCtrl,
                            icon: Iconsax.user,
                            hint: isAr ? 'اسم المستخدم' : 'Username',
                            textDirection: TextDirection.ltr,
                            focusNode: _usernameFocusNode,
                          ),
                        ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1),

                        const SizedBox(height: 12),

                        // Password
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(5),
                          child: _buildTextField(
                            controller: _passwordCtrl,
                            icon: Iconsax.lock,
                            hint: isAr ? 'كلمة المرور' : 'Password',
                            textDirection: TextDirection.ltr,
                            obscure: _obscure,
                            focusNode: _passwordFocusNode,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Iconsax.eye_slash : Iconsax.eye,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            onSubmitted: (_) => _login(),
                          ),
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                        const SizedBox(height: 28),

                        // Login Button
                        FocusTraversalOrder(
                          order: const NumericFocusOrder(6),
                          child: TVFocusable(
                            focusNode: _loginBtnFocusNode,
                            focusColor: AppColors.primary,
                            borderRadius: 14,
                            onSelect: _isLoading ? null : _login,
                            child: SizedBox(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isAr ? 'تسجيل الدخول' : 'Sign In',
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Iconsax.arrow_right_3,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                        const SizedBox(height: 24),

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
                                TVFocusable(
                                  borderRadius: 8,
                                  focusColor: AppColors.info,
                                  onSelect: () => launchUrl(
                                    Uri.parse(provider.telegramLink),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () => launchUrl(
                                      Uri.parse(provider.telegramLink),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    icon: const Icon(
                                      Iconsax.send_2,
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
                                ),
                              if (provider.whatsappLink.isNotEmpty)
                                TVFocusable(
                                  borderRadius: 8,
                                  focusColor: AppColors.success,
                                  onSelect: () => launchUrl(
                                    Uri.parse(provider.whatsappLink),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () => launchUrl(
                                      Uri.parse(provider.whatsappLink),
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    icon: const Icon(
                                      Iconsax.messages_3,
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
                                ),
                            ],
                          ).animate().fadeIn(delay: 700.ms),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextDirection? textDirection,
    bool obscure = false,
    Widget? suffixIcon,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
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
        focusNode: focusNode,
        style: const TextStyle(color: AppColors.textPrimary),
        onSubmitted: onSubmitted,
        textInputAction: onSubmitted != null
            ? TextInputAction.done
            : TextInputAction.next,
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
