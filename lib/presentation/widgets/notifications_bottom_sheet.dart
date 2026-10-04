import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../features/notification/bloc/notification_bloc.dart';
import '../../features/notification/bloc/notification_event.dart';
import '../../features/notification/bloc/notification_state.dart';
import '../../models/notification_info.dart';

/// Restyled Notifications Bottom Sheet matching exact specification
class NotificationsBottomSheet extends StatefulWidget {
  const NotificationsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8006282C), // rgba(6,40,44,0.5) dark teal scrim
      elevation: 0,
      builder: (sheetContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: const NotificationsBottomSheet(),
        );
      },
    );
  }

  @override
  State<NotificationsBottomSheet> createState() =>
      _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final curve = CurvedAnimation(
      parent: _animController,
      curve: const Cubic(0.2, 0.8, 0.2, 1.0),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 40), // slides up 40px while fading in
      end: Offset.zero,
    ).animate(curve);

    _animController.forward();
    context.read<NotificationBloc>().add(const ConnectNotificationStream());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final sheetHeight = mediaQuery.size.height * 0.78;
    final isReducedMotion = mediaQuery.accessibleNavigation;

    Widget content = Container(
      height: sheetHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 10, 24, 20 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle (40x4px pill, rgba(8,115,124,0.22))
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x3808737C),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Row (Space-between: Title & Close text button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary, // #0D2E31
                  letterSpacing: -0.48, // -0.02em
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.only(left: 16, right: 4),
                    alignment: Alignment.center,
                    child: Text(
                      'Close',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary, // #08737C
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Notification Content or Empty State
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                List<NotificationInfo> notifications = [];

                if (state is NotificationConnected) {
                  notifications = [state.notification];
                }

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildNotificationList(notifications);
              },
            ),
          ),
        ],
      ),
    );

    if (!isReducedMotion) {
      content = AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: _slideAnim.value,
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return Semantics(
      label: 'Notifications',
      container: true,
      child: content,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration (84x84, 26px above title)
            const SizedBox(
              width: 84,
              height: 84,
              child: CustomPaint(
                painter: _EmptyNotificationIllustrationPainter(),
              ),
            ),
            const SizedBox(height: 26),

            // Title: "No new notifications"
            Text(
              'No new notifications',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // #0D2E31
                letterSpacing: -0.315, // -0.015em
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Text(
                "You're all caught up with your startup applications and certificates.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary, // #5E7679
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationInfo> notifications) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      separatorBuilder: (context, index) {
        return Container(
          height: 1,
          color: const Color(0x1F08737C), // 1px divider rgba(8,115,124,0.12)
        );
      },
      itemBuilder: (context, index) {
        final item = notifications[index];
        final isUnread = item.read != true;

        return _NotificationRow(
          notification: item,
          isUnread: isUnread,
        );
      },
    );
  }
}

class _NotificationRow extends StatefulWidget {
  final NotificationInfo notification;
  final bool isUnread;

  const _NotificationRow({
    required this.notification,
    required this.isUnread,
  });

  @override
  State<_NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<_NotificationRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.notification;
    final title = item.type ?? 'System Notification';
    final message = item.message ?? 'No additional details';
    final dateText = item.createdAt ?? 'Just now';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Keep existing tap behavior
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0x0F08737C) : Colors.transparent, // rgba(8,115,124,0.06) on press
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 8px #F7A03A dot for unread (12px gap before text)
            if (widget.isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6, right: 12),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary, // #F7A03A
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 4),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title: 16px semibold/bold #0D2E31
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: widget.isUnread
                          ? FontWeight.w700 // Bold for unread
                          : FontWeight.w600, // Semibold for read
                      color: AppColors.textPrimary, // #0D2E31
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Message: 13.5px line-height 1.45 #5E7679
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary, // #5E7679
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Time/Date: 12.5px #5E7679
                  Text(
                    dateText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary, // #5E7679
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
}

/// Custom Painter for the 84x84 Empty State Illustration:
/// Outline bell in #08737C (2.5px stroke) + #F7A03A badge with white check mark (2.6px stroke)
class _EmptyNotificationIllustrationPainter extends CustomPainter {
  const _EmptyNotificationIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = AppColors.primary // #08737C
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width * 0.46, size.height * 0.52);

    // 1. Bell Dome & Body Path
    final bellPath = Path();
    // Top loop handle
    bellPath.addArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy - 22), radius: 5),
      0,
      -3.14159,
    );
    // Bell main flare outline
    bellPath.moveTo(center.dx - 16, center.dy + 12);
    bellPath.quadraticBezierTo(
      center.dx - 16,
      center.dy - 12,
      center.dx - 11,
      center.dy - 16,
    );
    bellPath.quadraticBezierTo(
      center.dx,
      center.dy - 22,
      center.dx + 11,
      center.dy - 16,
    );
    bellPath.quadraticBezierTo(
      center.dx + 16,
      center.dy - 12,
      center.dx + 16,
      center.dy + 12,
    );
    bellPath.lineTo(center.dx - 16, center.dy + 12);

    canvas.drawPath(bellPath, tealPaint);

    // 2. Bell Clapper Arc at bottom
    final clapperPath = Path();
    clapperPath.addArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 12), radius: 5),
      0,
      3.14159,
    );
    canvas.drawPath(clapperPath, tealPaint);

    // 3. Orange Checkmark Badge at Top Right (x: 62, y: 22, radius: 11)
    const badgeCenter = Offset(62, 22);
    final orangeBadgePaint = Paint()
      ..color = AppColors.secondary // #F7A03A
      ..style = PaintingStyle.fill;

    canvas.drawCircle(badgeCenter, 11, orangeBadgePaint);

    // White Checkmark inside Badge (2.6px stroke)
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(badgeCenter.dx - 4, badgeCenter.dy);
    checkPath.lineTo(badgeCenter.dx - 1, badgeCenter.dy + 3);
    checkPath.lineTo(badgeCenter.dx + 4.5, badgeCenter.dy - 3);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
