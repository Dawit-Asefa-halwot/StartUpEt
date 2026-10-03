import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../features/application/bloc/application_bloc.dart';
import '../../features/application/bloc/application_state.dart';
import '../../models/user.dart';
import 'metric_card.dart';
import 'notifications_bottom_sheet.dart';

class StartupDashboardView extends StatelessWidget {
  final User user;
  final Function(int) onNavigateTab;

  const StartupDashboardView({
    super.key,
    required this.user,
    required this.onNavigateTab,
  });

  String _getFirstName(String? name) {
    if (name == null || name.trim().isEmpty) return 'User';
    return name.trim().split(' ').first;
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _getFirstName(user.name);
    final initials = _getInitials(user.name);
    final role = user.role ?? 'USER';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 145.0,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          title: Text(
            'Welcome, $firstName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => NotificationsBottomSheet.show(context),
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A4D62),
                // gradient: LinearGradient(
                //   colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 78, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity( 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StartupET Mobile Dashboard',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity( 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.tealAccent.withOpacity( 0.7),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Dashboard Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary Hero CTA: Apply New Startup Application
                // Container(
                //   width: double.infinity,
                //   height: 56,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(16),
                //     gradient: const LinearGradient(
                //       colors: [Color(0xFF0A4D62), Color(0xFF0A4D68)],
                //       begin: Alignment.centerLeft,
                //       end: Alignment.centerRight,
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color: const Color(0xFF0A4D62).withOpacity( 0.3),
                //         blurRadius: 14,
                //         offset: const Offset(0, 6),
                //       ),
                //     ],
                //   ),
                //   child: Material(
                //     color: Colors.transparent,
                //     child: InkWell(
                //       onTap: () => onNavigateTab(1),
                //       borderRadius: BorderRadius.circular(16),
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 18),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Row(
                //               children: [
                //                 Container(
                //                   padding: const EdgeInsets.all(7),
                //                   decoration: BoxDecoration(
                //                     color: Colors.white.withOpacity( 0.15),
                //                     borderRadius: BorderRadius.circular(10),
                //                   ),
                //                   child: const Icon(
                //                     Icons.add_circle_outline,
                //                     color: Colors.white,
                //                     size: 20,
                //                   ),
                //                 ),
                //                 const SizedBox(width: 12),
                //                 const Text(
                //                   'Apply New Startup Application',
                //                   style: TextStyle(
                //                     fontSize: 14.5,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.white,
                //                     letterSpacing: -0.2,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //             const Icon(
                //               Icons.arrow_forward_ios,
                //               color: Colors.white70,
                //               size: 14,
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 26),

                // Live Metric Cards Grid Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Overview & Activity',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                BlocBuilder<ApplicationBloc, ApplicationState>(
                  builder: (context, appState) {
                    int fundingApps = 0;
                    int approvedApps = 0;
                    int pendingApps = 0;
                    int upcomingDeadlines = 0;

                    if (appState is ApplicationListLoaded) {
                      final apps = appState.applications;
                      if (apps.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withOpacity( 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity( 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.inbox_outlined,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No Applications Found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You haven\'t submitted any startup or funding applications yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => onNavigateTab(1),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'Create Application',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
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
                    }

                    final successRate = (fundingApps > 0)
                        ? ((approvedApps / fundingApps) * 100).toStringAsFixed(
                            0,
                          )
                        : '0';

                    return GridView.count(
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
                          color: const Color(0xFF2563EB),
                          onTap: () => onNavigateTab(1),
                        ),
                        MetricCard(
                          title: 'Approved',
                          value: '$approvedApps',
                          subtitle: '$successRate% success rate',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF059669),
                          onTap: () => onNavigateTab(1),
                        ),
                        MetricCard(
                          title: 'Pending Reports',
                          value: '$pendingApps',
                          subtitle: pendingApps > 0
                              ? '$pendingApps under review'
                              : 'No pending reports',
                          icon: Icons.description_outlined,
                          color: const Color(0xFFD97706),
                          onTap: () => onNavigateTab(1),
                        ),
                        MetricCard(
                          title: 'Upcoming Deadlines',
                          value: '$upcomingDeadlines',
                          subtitle: 'No upcoming deadlines',
                          icon: Icons.alarm_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 26),

                // Startup Certification Status Preview Card
                // CertificationPreviewCard(onNavigateTab: onNavigateTab),
                // const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
