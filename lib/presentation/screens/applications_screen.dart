import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_colors.dart';
import '../../features/application/bloc/application_bloc.dart';
import '../../features/application/bloc/application_event.dart';
import '../../features/application/bloc/application_state.dart';
import '../../models/application.dart';
import '../widgets/notifications_bottom_sheet.dart';
import '../widgets/startup_dashboard_view.dart';
import 'new_application_wizard_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ApplicationBloc>().add(const FetchApplications());
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Solid Header Container
          _buildHeader(context, topPadding),

          // Body Content Area
          Expanded(
            child: BlocBuilder<ApplicationBloc, ApplicationState>(
              builder: (context, state) {
                if (state is ApplicationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ApplicationError) {
                  final isNotFound =
                      state.message.contains('404') ||
                      state.message.toLowerCase().contains('not found') ||
                      state.message.toLowerCase().contains('no applications');

                  if (!isNotFound) {
                    return _buildErrorState(context);
                  }
                }

                List<Application> apps = [];
                if (state is ApplicationListLoaded) {
                  apps = state.applications;
                }

                return _buildApplicationsContent(context, apps, bottomInset);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, topPadding + 28, 0, 22),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Screen Title "Applications" & Notification Bell
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Applications',
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
          const SizedBox(height: 22),

          // Filter Tabs Row: All, Drafts, Under review, Completed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _buildFilterChip(0, 'All')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterChip(1, 'Drafts')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterChip(2, 'Under review')),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterChip(3, 'Completed')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Applications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and tap retry to refresh.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                context.read<ApplicationBloc>().add(
                      const FetchApplications(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsContent(
    BuildContext context,
    List<Application> allApps,
    double bottomInset,
  ) {
    String? filterStatus;
    if (_selectedTabIndex == 1) filterStatus = 'DRAFT';
    if (_selectedTabIndex == 2) filterStatus = 'UNDER_REVIEW';
    if (_selectedTabIndex == 3) filterStatus = 'COMPLETED';

    final filtered = filterStatus == null
        ? allApps
        : allApps.where((a) {
            final st = a.status.toUpperCase();
            if (filterStatus == 'UNDER_REVIEW') {
              return st == 'UNDER_REVIEW' ||
                  st == 'PENDING' ||
                  st == 'SUBMITTED';
            }
            if (filterStatus == 'COMPLETED') {
              return st == 'COMPLETED' || st == 'APPROVED';
            }
            return st == filterStatus;
          }).toList();

    if (filtered.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          left: 36,
          right: 36,
          bottom: 110 + bottomInset,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ApplicationBloc>().add(const FetchApplications());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: _buildEmptyState(context),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApplicationBloc>().add(const FetchApplications());
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 110 + bottomInset),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final app = filtered[index];
          return _buildApplicationCard(context, app);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const LineIllustration(),
        const SizedBox(height: 28),
        Text(
          'No applications found',
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
            'Start your official Ethiopian Startup Certification process below.',
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
          label: 'Start new application',
          onPressed: () => _showCreateApplicationDialog(context),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(BuildContext context, Application app) {
    final statusColor = _getStatusColor(app.status);
    final startupName =
        app.data?['startupName']?.toString() ??
        app.data?['startup_name']?.toString() ??
        'Startup Application';
    final initial = startupName.trim().isNotEmpty
        ? startupName.trim()[0].toUpperCase()
        : 'S';

    final industry =
        app.data?['industry']?.toString() ??
        app.data?['sector']?.toString() ??
        'General';
    final category =
        app.type ??
        app.data?['typeOfCompany']?.toString() ??
        app.data?['stage']?.toString() ??
        'INITIAL';

    String formattedDate = 'Recently';
    if (app.createdAt != null && app.createdAt!.isNotEmpty) {
      try {
        final dt = DateTime.parse(app.createdAt!);
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        formattedDate =
            '${monthNames[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
      } catch (_) {
        formattedDate = app.createdAt!;
      }
    }

    final bool isDraft = app.status.toUpperCase() == 'DRAFT';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C08737C),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isDraft) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NewApplicationWizardScreen(existingApplication: app),
                ),
              );
            } else {
              _showApplicationDetailBottomSheet(context, app);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Identity (Avatar + Title) & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            startupName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Filed on $formattedDate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        app.status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                // Details Row: Focus (Industry) & Category
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FOCUS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  industry,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CATEGORY',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.stars_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  category,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bottom Actions Button
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isDraft) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewApplicationWizardScreen(
                              existingApplication: app,
                            ),
                          ),
                        );
                      } else {
                        _showApplicationDetailBottomSheet(context, app);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDraft
                          ? AppColors.primary
                          : const Color(0xFFF8FAFC),
                      foregroundColor: isDraft
                          ? Colors.white
                          : AppColors.primary,
                      elevation: 0,
                      side: isDraft
                          ? BorderSide.none
                          : BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    icon: Icon(
                      isDraft
                          ? Icons.edit_note_rounded
                          : Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(
                      isDraft ? 'Continue Application' : 'View Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showApplicationDetailBottomSheet(
    BuildContext context,
    Application app,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final statusColor = _getStatusColor(app.status);
        final name =
            app.data?['startupName']?.toString() ?? 'Startup Application';
        final industry =
            app.data?['industry']?.toString() ?? 'General Technology';
        final stage = app.data?['stage']?.toString() ?? 'Early Stage';
        final phone = app.data?['phone']?.toString() ?? 'N/A';
        final email = app.data?['email']?.toString() ?? 'N/A';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      app.status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$industry • $stage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 24),
              _detailRow('Application ID', app.id),
              _detailRow('Email Contact', email),
              _detailRow('Phone Number', phone),
              if (app.createdAt != null)
                _detailRow('Submitted Date', app.createdAt.toString()),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return AppColors.textSecondary;
      case 'CERTIFIED':
      case 'APPROVED':
      case 'COMPLETED':
        return AppColors.primary;
      case 'UNDER_REVIEW':
      case 'PENDING':
      case 'SUBMITTED':
        return AppColors.secondary;
      case 'REJECTED':
        return const Color(0xFFE53E3E);
      default:
        return AppColors.primary;
    }
  }

  void _showCreateApplicationDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewApplicationWizardScreen(),
      ),
    );
  }
}
