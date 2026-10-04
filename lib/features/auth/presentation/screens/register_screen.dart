import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_colors.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'USER';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      final rawPhone = _phoneNumberController.text.trim();
      final phonePayload =
          rawPhone.startsWith('+251') ? rawPhone : '+251$rawPhone';

      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: phonePayload,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRequireVerification) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerifyEmailScreen(initialEmail: state.email),
              ),
            );
          } else if (state is AuthError) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Registration Error',
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          } else if (state is AuthVerifiedSuccessfully) {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Email Verified!',
                message: state.message,
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);

            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              topPadding + 16,
              24,
              24 + bottomInset,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Row: Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0x1A08737C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Logo & Tagline
                  Image.asset('assets/logo.png', height: 72),
                  const SizedBox(height: 8),
                  Text(
                    'Ethiopian Startup Ecosystem',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.27,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Title "Create account"
                  Text(
                    'Create account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.52,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Fields Group (14px vertical gap)
                  // 1. First Name | Last Name Two Columns
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: _buildInputDecoration('First name'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: _buildInputDecoration('Last name'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Email Address
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: _buildInputDecoration('Email address'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 3. Phone Number (+251 prefix)
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: _buildInputDecoration(
                      '91 234 5678',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+251',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0x3808737C),
                            ),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 4. Role / Category Custom Dropdown
                  _CustomRoleDropdown(
                    selectedValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // 5. Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: _buildInputDecoration(
                      'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 22,
                            color: _obscurePassword
                                ? AppColors.textSecondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // 6. Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: _buildInputDecoration(
                      'Confirm password',
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 22,
                            color: _obscureConfirmPassword
                                ? AppColors.textSecondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Main Button "Create account"
                  PressableCreateAccountButton(
                    isLoading: isLoading,
                    onPressed: _submitRegistration,
                  ),
                  const SizedBox(height: 22),

                  // Sign-in Link
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF8DA3A6),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x3808737C)),
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
    );
  }
}

/// Custom Overlay Role Dropdown Widget matching exact design specification
class _CustomRoleDropdown extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _CustomRoleDropdown({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<_CustomRoleDropdown> createState() => _CustomRoleDropdownState();
}

class _CustomRoleDropdownState extends State<_CustomRoleDropdown> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  static const Map<String, String> _options = {
    'USER': 'Startup (Individual/Company)',
    'ECOSYSTEM_BUILDER': 'Ecosystem builder',
  };

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 6),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x3808737C)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x5208737C),
                        blurRadius: 34,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _options.entries.map((entry) {
                      final isSelected = entry.key == widget.selectedValue;
                      return InkWell(
                        onTap: () {
                          widget.onChanged(entry.key);
                          _closeDropdown();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0x1A08737C)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.value,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        _options[widget.selectedValue] ?? 'Startup (Individual/Company)';

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x3808737C)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: -7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: AppColors.background,
              child: Text(
                'Role / category',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Pressable Create Account Button with 0.98 scale animation
class PressableCreateAccountButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PressableCreateAccountButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<PressableCreateAccountButton> createState() =>
      _PressableCreateAccountButtonState();
}

class _PressableCreateAccountButtonState
    extends State<PressableCreateAccountButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _isPressed ? AppColors.primaryDark : AppColors.primary,
          borderRadius: BorderRadius.circular(27),
          boxShadow: const [
            BoxShadow(
              color: Color(0x7F08737C),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(27),
          child: InkWell(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(27),
            child: Center(
              child: widget.isLoading
                  ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                  : Text(
                      'Create account',
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
    );
  }
}
