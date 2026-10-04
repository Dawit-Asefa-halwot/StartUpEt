import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';

/// Representation of a single dot in the animated network background
class NetworkDot {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  bool isOrange;

  NetworkDot({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.isOrange,
  });
}

/// Custom painter for the animated startup network background
class AnimatedNetworkPainter extends CustomPainter {
  final List<NetworkDot> dots;

  AnimatedNetworkPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    final whiteDotPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final orangeDotPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw connection lines between dots closer than 120px
    for (int i = 0; i < dots.length; i++) {
      for (int j = i + 1; j < dots.length; j++) {
        final dx = dots[i].x - dots[j].x;
        final dy = dots[i].y - dots[j].y;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < 120.0) {
          final opacity = (0.2 * (1.0 - distance / 120.0)).clamp(0.0, 1.0);
          linePaint.color = Colors.white.withOpacity(opacity);
          canvas.drawLine(
            Offset(dots[i].x, dots[i].y),
            Offset(dots[j].x, dots[j].y),
            linePaint,
          );
        }
      }
    }

    // Draw dots
    for (final dot in dots) {
      final paint = dot.isOrange ? orangeDotPaint : whiteDotPaint;
      canvas.drawCircle(Offset(dot.x, dot.y), dot.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedNetworkPainter oldDelegate) => true;
}

/// Custom painter for the 40x40 custom loader spinner
class CustomSpinnerPainter extends CustomPainter {
  final double animationValue;

  CustomSpinnerPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle (white at 20% opacity)
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Active arc (#F7A03A orange, covering ~62% of circle, rounded caps)
    final arcPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = animationValue * 2 * math.pi;
    const sweepAngle = 2 * math.pi * 0.62;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomSpinnerPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// In-App Loading Splash Screen matching Part B specification
class InAppLoadingSplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const InAppLoadingSplashScreen({super.key, this.onComplete});

  @override
  State<InAppLoadingSplashScreen> createState() =>
      _InAppLoadingSplashScreenState();
}

class _InAppLoadingSplashScreenState extends State<InAppLoadingSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _networkController;
  late AnimationController _rippleController;
  late AnimationController _logoIntroController;
  late AnimationController _spinnerController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoTranslation;

  final List<NetworkDot> _dots = [];
  final math.Random _random = math.Random();
  bool _isInitializedDots = false;

  @override
  void initState() {
    super.initState();

    // 1. Network Controller (60 FPS loop)
    _networkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateNetworkDots);

    // 2. Ripple Controller (3.6s loop)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // 3. Logo Intro Controller (1.0s)
    _logoIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    const curve = Cubic(0.2, 0.8, 0.2, 1.0);
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoIntroController, curve: curve),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _logoIntroController, curve: curve),
    );
    _logoTranslation = Tween<Offset>(
      begin: const Offset(0, 12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoIntroController, curve: curve),
    );

    // 4. Spinner Controller (1.1s linear loop)
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Start continuous animations
    _networkController.repeat();
    _rippleController.repeat();
    _spinnerController.repeat();
    _logoIntroController.forward();
  }

  void _initDots(Size size) {
    if (_isInitializedDots || size.width == 0 || size.height == 0) return;
    _isInitializedDots = true;

    final dotCount =
        math.min(60, (size.width * size.height / 9000).round()).clamp(15, 60);

    _dots.clear();
    for (int i = 0; i < dotCount; i++) {
      final isOrange = _random.nextDouble() < 0.12;
      final baseRadius = 1.0 + _random.nextDouble() * 1.8; // 1.0 - 2.8px
      final radius = isOrange ? baseRadius + 0.8 : baseRadius;

      // Random velocity up to 0.14 px per frame
      final vx = (_random.nextDouble() * 0.28 - 0.14);
      final vy = (_random.nextDouble() * 0.28 - 0.14);

      _dots.add(
        NetworkDot(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          vx: vx,
          vy: vy,
          radius: radius,
          isOrange: isOrange,
        ),
      );
    }
  }

  void _updateNetworkDots() {
    if (!mounted || _dots.isEmpty) return;
    final size = MediaQuery.of(context).size;

    setState(() {
      for (final dot in _dots) {
        dot.x += dot.vx;
        dot.y += dot.vy;

        // Bounce off screen edges
        if (dot.x <= 0 || dot.x >= size.width) {
          dot.vx = -dot.vx;
          dot.x = dot.x.clamp(0, size.width);
        }
        if (dot.y <= 0 || dot.y >= size.height) {
          dot.vy = -dot.vy;
          dot.y = dot.y.clamp(0, size.height);
        }
      }
    });
  }

  @override
  void dispose() {
    _networkController.dispose();
    _rippleController.dispose();
    _logoIntroController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isReducedMotion = MediaQuery.of(context).accessibleNavigation;

    _initDots(screenSize);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Layer 1: Radial Gradient Background (Center 50% H, 44% V)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.12), // 44% V center
                  radius: 1.25,
                  colors: [
                    Color(0xFF0D8D98), // 0%
                    Color(0xFF08737C), // 38%
                    Color(0xFF055058), // 72%
                    Color(0xFF033A40), // 100%
                  ],
                  stops: [0.0, 0.38, 0.72, 1.0],
                ),
              ),
            ),

            // Layer 2: Animated Network (Dots & Lines)
            if (!isReducedMotion)
              CustomPaint(
                size: screenSize,
                painter: AnimatedNetworkPainter(dots: _dots),
              ),

            // Layer 3: Ripples (Centered behind logo at 44% height)
            if (!isReducedMotion)
              Positioned(
                top: screenSize.height * 0.44 - 75,
                left: screenSize.width / 2 - 75,
                child: AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildRippleCircle(_rippleController.value, 0.0),
                          _buildRippleCircle(_rippleController.value, 1.2 / 3.6),
                          _buildRippleCircle(_rippleController.value, 2.4 / 3.6),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Layer 4: Logo (Centered at 44% height, width 236px)
            Positioned(
              top: screenSize.height * 0.44 - 36,
              left: (screenSize.width - 236) / 2,
              child: isReducedMotion
                  ? _buildLogoImage()
                  : AnimatedBuilder(
                      animation: _logoIntroController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: _logoTranslation.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: _buildLogoImage(),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Layer 5: Loading Indicator & Text (Bottom area)
            Positioned(
              left: 0,
              right: 0,
              bottom: 44 + bottomInset,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 40x40 Circular Spinner
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: isReducedMotion
                        ? CustomPaint(
                            painter: CustomSpinnerPainter(animationValue: 0.0),
                          )
                        : AnimatedBuilder(
                            animation: _spinnerController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CustomSpinnerPainter(
                                  animationValue: _spinnerController.value,
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 18),

                  // Tagline Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'ETHIOPIAN STARTUP ECOSYSTEM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 2.64, // 0.22em
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRippleCircle(double progress, double delayFraction) {
    final effectiveProgress = (progress - delayFraction) % 1.0;
    // Scale 1.0x to 3.4x, Opacity 0.55 to 0.0 over curve (0.2, 0.6, 0.3, 1.0)
    const rippleCurve = Cubic(0.2, 0.6, 0.3, 1.0);
    final curveVal = rippleCurve.transform(effectiveProgress);

    final scale = 1.0 + (3.4 - 1.0) * curveVal;
    final opacity = (0.55 * (1.0 - curveVal)).clamp(0.0, 1.0);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(opacity),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoImage() {
    return Container(
      width: 236,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x47000000), // rgba(0,0,0,0.28)
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Image.asset(
        'assets/logo.png',
        width: 236,
        fit: BoxFit.contain,
        color: Colors.white.withOpacity(0.95),
        colorBlendMode: BlendMode.modulate,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.rocket_launch,
            size: 64,
            color: Colors.white,
          );
        },
      ),
    );
  }
}
