import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../features/application/bloc/application_bloc.dart';
import '../../features/application/bloc/application_state.dart';
import '../../models/user.dart';
import 'metric_card.dart';
import 'notifications_bottom_sheet.dart';

/// Simple line illustration (84x84) representing an outlined document
/// with an orange filled circle containing a white plus at the bottom-right.
class LineIllustration extends StatelessWidget {
  const LineIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Outlined Document Container
          Positioned(
            left: 12,
            top: 4,
            child: Container(
              width: 52,
              height: 66,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 2.5,
                    width: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 2.5,
                    width: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 2.5,
                    width: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filled Orange Circle with Plus Icon at Bottom-Right
          Positioned(
            right: 10,
            bottom: 6,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pressable Create Application Button with 0.98 scale animation and hover/press state
class PressableCreateButton extends StatefulWidget {
  final VoidCallback onPressed;

  const PressableCreateButton({super.key, required this.onPressed});

  @override
  State<PressableCreateButton> createState() => _PressableCreateButtonState();
}

class _PressableCreateButtonState extends State<PressableCreateButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
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
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(27),
            child: Center(
              child: Text(
                'Create application',
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

/// Restyled StartupDashboardView matching exact design specification
class StartupDashboardView extends StatelessWidget {
  final User user;
  final Function(int) onNavigateTab;

  const StartupDashboardView({
    super.key,
    required this.user,
    required this.onNavigateTab,
  });

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'AF';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user.name);
    final userName = user.name ?? 'Abebe Feleke';
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Solid Header Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, topPadding + 28, 24, 64),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Avatar and Text Stack
                Row(
                  children: [
                    // Avatar: 44x44 circle with initials
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Text Stack
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.33,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Welcome back',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right: Notification Bell Button (44x44)
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => NotificationsBottomSheet.show(context),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          // Unread Notification Dot
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
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

          // Content Area (Expands to fill remaining height)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                left: 36,
                right: 36,
                bottom: 100 + bottomInset,
              ),
              child: BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, appState) {
                  int fundingApps = 0;
                  int approvedApps = 0;
                  int pendingApps = 0;
                  int upcomingDeadlines = 0;

                  if (appState is ApplicationListLoaded) {
                    final apps = appState.applications;
                    if (apps.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    fundingApps = apps
                        .where(
                          (a) =>
                              a.type == 'FUNDING' ||
                              a.data?['type'] == 'FUNDING',
                        )
                        .length;
                    approvedApps = apps
                        .where(
                          (a) =>
                              a.status.toUpperCase() == 'CERTIFIED' ||
                              a.status.toUpperCase() == 'APPROVED',
                        )
                        .length;
                    pendingApps = apps
                        .where(
                          (a) =>
                              a.status.toUpperCase() == 'PENDING' ||
                              a.status.toUpperCase() == 'UNDER_REVIEW',
                        )
                        .length;
                  } else {
                    return _buildEmptyState(context);
                  }

                  final successRate = (fundingApps > 0)
                      ? ((approvedApps / fundingApps) * 100).toStringAsFixed(0)
                      : '0';

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.25,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      children: [
                        MetricCard(
                          title: 'Funding Applications',
                          value: '$fundingApps',
                          subtitle: 'Across all programs',
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          onTap: () => onNavigateTab(1),
                        ),
                        MetricCard(
                          title: 'Approved',
                          value: '$approvedApps',
                          subtitle: '$successRate% success rate',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.secondary,
                          onTap: () => onNavigateTab(1),
                        ),
                        MetricCard(
                          title: 'Pending Reports',
                          value: '$pendingApps',
                          subtitle: pendingApps > 0
                              ? '$pendingApps under review'
                              : 'No pending reports',
                          icon: Icons.description_outlined,
                          color: AppColors.secondary,
                          onTap: () => onNavigateTab(1),
                        ),
                        MetricCard(
                          title: 'Upcoming Deadlines',
                          value: '$upcomingDeadlines',
                          subtitle: 'No upcoming deadlines',
                          icon: Icons.alarm_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Centered Empty State Widget (no card wrapper, sits directly on background)
  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const LineIllustration(),
        const SizedBox(height: 28),
        Text(
          'No applications yet',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            'Apply for startup support or funding and track every submission here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        PressableCreateButton(
          onPressed: () => onNavigateTab(1),
        ),
      ],
    );
  }
}
