import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'policy_viewer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pauseNotifications = true;
  bool _darkMode = true;

  String _userName = 'Crypto Researcher';

  String _userHandle = '@cryptoresearcher';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.name;
        _userHandle = user.email.contains('@') ? '@${user.email.split('@')[0]}' : user.email;
      });
    } else {
      final name = await AuthService.getUserName();
      final email = await AuthService.getUserEmail();
      if (mounted && (name != null || email != null)) {
        setState(() {
          if (name != null && name.isNotEmpty) {
            _userName = name;
          }
          if (email != null && email.isNotEmpty) {
            _userHandle = email.contains('@') ? '@${email.split('@')[0]}' : email;
          }
        });
      }
    }
  }

  void _showEditProfileSheet() {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final nameCtrl = TextEditingController(text: currentUser?.name ?? _userName);
    final passwordCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentUser?.email ?? 'user@cryptoresearch.com',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Full Name', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.secondary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('New Password (Optional)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter new password if updating',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.secondary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final newName = nameCtrl.text.trim();
                              final newPass = passwordCtrl.text.trim();
                              if (newName.isEmpty) return;

                              final messenger = ScaffoldMessenger.of(context);
                              setSheetState(() => isSaving = true);
                              final ok = await authProvider.updateProfile(
                                name: newName,
                                password: newPass.isNotEmpty ? newPass : null,
                              );
                              setSheetState(() => isSaving = false);

                              if (!sheetCtx.mounted) return;
                              Navigator.of(sheetCtx).pop();

                              setState(() {
                                _userName = newName;
                              });

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Profile updated successfully via API!'
                                        : (authProvider.errorMessage ?? 'Update saved locally.'),
                                  ),
                                  backgroundColor: ok ? AppColors.primary : AppColors.cardHighlight,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text('Save Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLogout01,
                size: 22,
                color: Color(0xFFFF5252),
              ),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of Crypto Research?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'No',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<AuthProvider>().logout();
                if (!mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => const LoginScreen(),
                    transitionsBuilder: (context, anim1, anim2, child) {
                      return FadeTransition(opacity: anim1, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFaqBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    'How is 24h market volume computed?',
                    'Volume aggregates trading turnover from leading global crypto exchanges updated every 60 seconds.',
                  ),
                  _buildFaqItem(
                    'Can I trade directly inside the app?',
                    'Crypto Research is an analytical intelligence platform designed for portfolio research and market tracking.',
                  ),
                  _buildFaqItem(
                    'How does watchlist synchronization work?',
                    'Your favorites are saved locally with immediate live indicator feedback.',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption('English (US)', isSelected: true),
                _buildLanguageOption('Tamil (தமிழ்)',isSelected: true),
                _buildLanguageOption('Hindi (हिन्दी)'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String lang, {bool isSelected = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        lang,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      trailing: isSelected
          ? const HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              size: 20,
              color: AppColors.primary,
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language set to $lang'),
            backgroundColor: AppColors.cardHighlight,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  void _showContactInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Support & Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Have inquiries or need help with research metrics? Reach our 24/7 desk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedMail01,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'support@cryptoresearch.io',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // User Profile Card (Reference Image - Interactive to edit profile via PUT /api/auth/profile)
              GestureDetector(
                onTap: _showEditProfileSheet,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card, // #282828
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE89B37),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUserCircle,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Name & Handle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userHandle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Group 1: Notifications & General Settings
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: HugeIcons.strokeRoundedNotification01,
                      title: 'Pause notifications',
                      value: _pauseNotifications,
                      onChanged: (val) {
                        setState(() {
                          _pauseNotifications = val;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: HugeIcons.strokeRoundedSettings01,
                      title: 'General settings',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('General settings panel opened'),
                            duration: Duration(milliseconds: 1200),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Group 2: Dark Mode, Language, My Contact
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: HugeIcons.strokeRoundedMoon02,
                      title: 'Dark mode',
                      value: _darkMode,
                      onChanged: (val) {
                        setState(() {
                          _darkMode = val;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: HugeIcons.strokeRoundedGlobe02,
                      title: 'Language',
                      onTap: _showLanguageSelector,
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: HugeIcons.strokeRoundedUserMultiple,
                      title: 'My Contact',
                      onTap: _showContactInfo,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Group 3: FAQ, Terms of Service, User Policy
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildNavigationTile(
                      icon: HugeIcons.strokeRoundedHelpCircle,
                      title: 'FAQ',
                      onTap: _showFaqBottomSheet,
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: HugeIcons.strokeRoundedInformationCircle,
                      title: 'Terms of service',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PolicyViewerScreen(
                              initialTabIndex: 1, // Terms of Service tab
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: HugeIcons.strokeRoundedFile01,
                      title: 'User policy',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PolicyViewerScreen(
                              initialTabIndex: 0, // Privacy Policy tab
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Bottom Log Out Button (Reference Image: White Pill with Red Icon & Text)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLogout01,
                    size: 20,
                    color: Color(0xFFFF5252),
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF5252),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required List<List<dynamic>> icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary, // #B4DE01 like reference
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.borderLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required List<List<dynamic>> icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: AppColors.border,
        height: 1,
        thickness: 0.8,
      ),
    );
  }
}
