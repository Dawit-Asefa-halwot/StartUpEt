import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/ecosystem/bloc/ecosystem_bloc.dart';
import '../../features/ecosystem/bloc/ecosystem_event.dart' hide EcosystemEvent;
import '../../features/ecosystem/bloc/ecosystem_state.dart';
import '../widgets/notifications_bottom_sheet.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAwesomeSnackbar(
    BuildContext context,
    String title,
    String message,
    ContentType contentType,
  ) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocListener<EcosystemBloc, EcosystemState>(
      listener: (context, state) {
        if (state is EcosystemApplicationSubmitted) {
          _showAwesomeSnackbar(
            context,
            'Application Submitted!',
            'Your Ecosystem Builder application is now under official review.',
            ContentType.success,
          );
        } else if (state is EcosystemError) {
          _showAwesomeSnackbar(
            context,
            'Submission Notice',
            state.message,
            ContentType.failure,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;

            final userName = user?.name ?? user?.email ?? 'Abebe Feleke';
            final email = user?.email ?? 'abebe@startupet.et';
            final role = user?.role ?? 'USER';
            final initial = userName.trim().isNotEmpty
                ? userName.trim()[0].toUpperCase()
                : 'A';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Solid Header Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(0, topPadding + 28, 0, 30),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title "Settings" & Logout Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Settings',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.52,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () =>
                                    _showLogoutConfirmationDialog(context),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Profile Row: Avatar & Text Stack
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 64x64 Circle Avatar
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                                image: user?.image != null &&
                                        user!.image!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(user.image!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (user?.image == null ||
                                      user!.image!.isEmpty)
                                  ? Center(
                                      child: Text(
                                        initial,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Text Stack
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    userName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    email,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.78),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  // Role Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      role.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.88,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      120 + bottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Menu Rows
                        _SettingsMenuRow(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit profile',
                          subtitle:
                              'Update name, phone number, location and avatar',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileScreen(user: user),
                              ),
                            );
                          },
                        ),
                        _SettingsMenuRow(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications and alerts',
                          subtitle: 'System notices and grant updates',
                          onTap: () => NotificationsBottomSheet.show(context),
                        ),
                        _SettingsMenuRow(
                          icon: Icons.work_outline_rounded,
                          title: 'Apply as ecosystem builder',
                          subtitle:
                              'Incubator, accelerator and hub manager application',
                          showDivider: false,
                          onTap: () => _showEcosystemBuilderDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEcosystemBuilderDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ecosystem builder application',
      barrierColor: const Color(0x8006282C), // rgba(6,40,44,0.5) dark teal scrim
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _EcosystemBuilderDialog(parentContext: context);
      },
      transitionBuilder:
          (dialogContext, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.8, 0.2, 1.0),
        );
        final isReducedMotion =
            MediaQuery.of(dialogContext).accessibleNavigation;

        if (isReducedMotion) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: child,
          );
        }

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6 * animation.value,
            sigmaY: 6 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: Transform.translate(
              offset: Offset(0, 8 * (1.0 - curve.value)),
              child: Transform.scale(
                scale: 0.95 + (0.05 * curve.value),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout Confirmation',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your StartupET account?',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const AuthLogout());
              },
              child: Text(
                'Logout',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsMenuRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsMenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  State<_SettingsMenuRow> createState() => _SettingsMenuRowState();
}

class _SettingsMenuRowState extends State<_SettingsMenuRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0x0F08737C) : Colors.transparent,
          border: widget.showDivider
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0x1F08737C),
                    width: 1,
                  ),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EcosystemBuilderDialog extends StatefulWidget {
  final BuildContext parentContext;

  const _EcosystemBuilderDialog({required this.parentContext});

  @override
  State<_EcosystemBuilderDialog> createState() =>
      _EcosystemBuilderDialogState();
}

class _EcosystemBuilderDialogState extends State<_EcosystemBuilderDialog> {
  final _formKey = GlobalKey<FormState>();

  final _orgNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();

  final _orgNameFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _websiteFocusNode = FocusNode();
  final _bioFocusNode = FocusNode();

  bool _isSubmitPressed = false;
  bool _isCancelPressed = false;

  @override
  void dispose() {
    _orgNameController.dispose();
    _typeController.dispose();
    _websiteController.dispose();
    _bioController.dispose();

    _orgNameFocusNode.dispose();
    _typeFocusNode.dispose();
    _websiteFocusNode.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? true) {
      final orgName = _orgNameController.text.trim();
      final type = _typeController.text.trim();
      final website = _websiteController.text.trim();
      final description = _bioController.text.trim();

      Navigator.pop(context);

      widget.parentContext.read<EcosystemBloc>().add(
            SubmitEcosystemApplication({
              'organizationName': orgName,
              'builderType': type,
              'website': website,
              'description': description,
            }),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Semantics(
      label: 'Ecosystem builder application',
      container: true,
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x73000000), // rgba(0,0,0,0.45)
                      blurRadius: 70,
                      offset: Offset(0, 30),
                      spreadRadius: -20,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Text(
                        'Ecosystem builder application',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary, // #0D2E31
                          letterSpacing: -0.44, // -0.02em
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // INTRO
                      Text(
                        'Tell us about your incubator, accelerator or hub.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary, // #5E7679
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // FIELD 1: Organization name
                      _buildFormField(
                        label: 'Organization name',
                        placeholder: 'Your organization',
                        controller: _orgNameController,
                        focusNode: _orgNameFocusNode,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // FIELD 2: Builder type
                      _buildFormField(
                        label: 'Builder type',
                        placeholder: 'e.g., Incubator, accelerator, hub',
                        controller: _typeController,
                        focusNode: _typeFocusNode,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // FIELD 3: Official website or portal
                      _buildFormField(
                        label: 'Official website or portal',
                        placeholder: 'https://www.example.com',
                        controller: _websiteController,
                        focusNode: _websiteFocusNode,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // FIELD 4: Mission and program overview
                      _buildFormField(
                        label: 'Mission and program overview',
                        placeholder: 'Describe your mission and programs',
                        controller: _bioController,
                        focusNode: _bioFocusNode,
                        isMultiLine: true,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 6),

                      // BUTTON 1: Submit application (Sentence case)
                      AnimatedScale(
                        scale: _isSubmitPressed ? 0.98 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: _isSubmitPressed
                                ? AppColors.primaryDark // #06565D
                                : AppColors.primary, // #08737C
                            borderRadius: BorderRadius.circular(27),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x7F08737C),
                                blurRadius: 22,
                                offset: Offset(0, 10),
                                spreadRadius: -8,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(27),
                            child: InkWell(
                              onTapDown: (_) =>
                                  setState(() => _isSubmitPressed = true),
                              onTapUp: (_) =>
                                  setState(() => _isSubmitPressed = false),
                              onTapCancel: () =>
                                  setState(() => _isSubmitPressed = false),
                              onTap: _submitForm,
                              borderRadius: BorderRadius.circular(27),
                              child: Center(
                                child: Text(
                                  'Submit application',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // BUTTON 2: Cancel button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTapDown: (_) =>
                                setState(() => _isCancelPressed = true),
                            onTapUp: (_) =>
                                setState(() => _isCancelPressed = false),
                            onTapCancel: () =>
                                setState(() => _isCancelPressed = false),
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _isCancelPressed
                                      ? AppColors.primary // #08737C on press
                                      : AppColors.textSecondary, // #5E7679
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isMultiLine = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (14px, semibold, #0D2E31, 8px above input)
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary, // #0D2E31
          ),
        ),
        const SizedBox(height: 8),

        // Input Box
        AnimatedBuilder(
          animation: focusNode,
          builder: (context, child) {
            final isFocused = focusNode.hasFocus;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: isFocused
                    ? const [
                        BoxShadow(
                          color: Color(0x2408737C), // rgba(8,115,124,0.14) 3px glow
                          blurRadius: 6,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                maxLines: isMultiLine ? 4 : 1,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary, // #0D2E31
                  height: isMultiLine ? 1.5 : 1.2,
                ),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF8DA3A6),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: isMultiLine
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x3808737C)), // 1px border rgba(8,115,124,0.22)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x3808737C)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD14343), width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD14343), width: 1.5),
                  ),
                  errorStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFD14343),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
