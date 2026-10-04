import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_colors.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
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
            final isUnverified =
                state.message.toLowerCase().contains('verify') ||
                    state.message.toLowerCase().contains('verified');
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: isUnverified ? 'Email Unverified' : 'Login Failed',
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                24,
                topPadding + 28,
                24,
                24 + bottomInset,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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

                    // Title "Sign in"
                    Text(
                      'Sign in',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.52,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Fields Group
                    // 1. Email Address
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'Email address',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
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

                    // 2. Password
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 2),

                    // Forgot Password Link (Centered)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Main Button "Sign in"
                    PressableLoginButton(
                      isLoading: isLoading,
                      onPressed: _submitLogin,
                    ),
                    const SizedBox(height: 18),

                    // Note
                    Container(
                      constraints: const BoxConstraints(maxWidth: 270),
                      child: Text(
                        'Creating an account does not mean submitting a startup application.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Create Account Link
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Create account',
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

/// Animated Pressable Login Button with 0.98 scale animation
class PressableLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PressableLoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<PressableLoginButton> createState() => _PressableLoginButtonState();
}

class _PressableLoginButtonState extends State<PressableLoginButton> {
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
                      'Sign in',
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
