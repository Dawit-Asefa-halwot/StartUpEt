import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../features/application/bloc/application_bloc.dart';
import '../../features/application/bloc/application_event.dart';
import '../../features/application/bloc/application_state.dart';
import '../../models/application.dart';
import 'new_application_wizard_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<ApplicationBloc>().add(const FetchApplications());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        // backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey[600],
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Drafts'),
            Tab(text: 'Under Review'),
            Tab(text: 'Completed'),
            Tab(text: 'Certified'),
          ],
        ),
      ),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 56,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to Load Applications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and tap retry to refresh.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
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
          }

          List<Application> apps = [];
          if (state is ApplicationListLoaded) {
            apps = state.applications;
          }

          return TabBarView(
            clipBehavior: Clip.none,
            controller: _tabController,
            children: [
              _buildApplicationsList(apps, null),
              _buildApplicationsList(apps, 'DRAFT'),
              _buildApplicationsList(apps, 'UNDER_REVIEW'),
              _buildApplicationsList(apps, 'COMPLETED'),
              _buildApplicationsList(apps, 'CERTIFIED'),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          elevation: 6,
          onPressed: () => _showCreateApplicationDialog(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'New Application',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList(
    List<Application> allApps,
    String? filterStatus,
  ) {
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
      return RefreshIndicator(
        onRefresh: () async {
          context.read<ApplicationBloc>().add(const FetchApplications());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No applications found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  filterStatus == null
                      ? 'Start your official Ethiopian Startup Certification process below.'
                      : 'No applications match filter "$filterStatus".',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
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
                  onPressed: () => _showCreateApplicationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Start New Application',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApplicationBloc>().add(const FetchApplications());
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final app = filtered[index];
          return _buildApplicationCard(context, app);
        },
      ),
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
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity( 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity( 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Filed on $formattedDate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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
                        color: statusColor.withOpacity( 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity( 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        app.status.toUpperCase(),
                        style: TextStyle(
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
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  industry,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
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
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.stars_outlined,
                                size: 14,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
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
                              color: AppColors.primary.withOpacity( 0.3),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                      style: const TextStyle(
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity( 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      app.status.toUpperCase(),
                      style: TextStyle(
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
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return Colors.blueGrey;
      case 'CERTIFIED':
      case 'APPROVED':
        return Colors.green;
      case 'UNDER_REVIEW':
      case 'PENDING':
      case 'SUBMITTED':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.blue;
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
