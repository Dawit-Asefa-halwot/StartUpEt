import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/app_colors.dart';
import '../../features/funding/bloc/funding_bloc.dart';
import '../../features/funding/bloc/funding_event.dart';
import '../../features/funding/bloc/funding_state.dart';
import '../../features/pitch/bloc/pitch_bloc.dart';
import '../../features/pitch/bloc/pitch_event.dart';
import '../../features/pitch/bloc/pitch_state.dart';
import '../../models/funding.dart';

class FundingScreen extends StatefulWidget {
  const FundingScreen({super.key});

  @override
  State<FundingScreen> createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<FundingBloc>().add(const FetchFunding());
    context.read<FundingBloc>().add(const FetchMyFundingApplications());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAwesomeSnackbar(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funding & Pitches'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available Grants'),
            Tab(text: 'My Applications'),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FundingBloc, FundingState>(
            listener: (context, state) {
              if (state is FundingApplied) {
                _showAwesomeSnackbar(
                  'Application Submitted!',
                  'Your funding application has been sent for review.',
                  ContentType.success,
                );
                context.read<FundingBloc>().add(
                  const FetchMyFundingApplications(),
                );
              } else if (state is FundingDetailLoaded) {
                _showAwesomeSnackbar(
                  'Opportunity Saved',
                  'Saved opportunity: ${state.detail.title}',
                  ContentType.success,
                );
              } else if (state is FundingError) {
                _showAwesomeSnackbar(
                  'Notice',
                  state.message,
                  ContentType.failure,
                );
              }
            },
          ),
          BlocListener<PitchBloc, PitchState>(
            listener: (context, state) {
              if (state is PitchCreated) {
                _showAwesomeSnackbar(
                  'Pitch Deck Submitted!',
                  'Your pitch deck has been forwarded to ecosystem investors.',
                  ContentType.success,
                );
              } else if (state is PitchError) {
                _showAwesomeSnackbar(
                  'Pitch Submission',
                  state.message,
                  ContentType.failure,
                );
              }
            },
          ),
        ],
        child: TabBarView(
          controller: _tabController,
          children: [_buildGrantsTab(), _buildMyApplicationsTab()],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitPitchDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.send),
        label: const Text('Submit Pitch'),
      ),
    );
  }

  Widget _buildGrantsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FundingBloc>().add(const FetchFunding());
      },
      child: BlocBuilder<FundingBloc, FundingState>(
        builder: (context, state) {
          if (state is FundingLoading) {
            return const Center(
              child: SpinKitThreeBounce(color: AppColors.primary, size: 30),
            );
          }

          if (state is FundingListLoaded) {
            final grants = state.funding;
            if (grants.isEmpty) {
              return _buildEmptyState(
                'No Active Funding',
                'New grant & investment rounds will appear here.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grants.length,
              itemBuilder: (context, index) {
                return _buildGrantCard(grants[index]);
              },
            );
          }

          return _buildEmptyState(
            'No Active Funding',
            'New grant & investment rounds will appear here.',
          );
        },
      ),
    );
  }

  Widget _buildGrantCard(Funding grant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    grant.status ?? 'Grant',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        context.read<FundingBloc>().add(
                          SaveFunding({'opportunityId': grant.id}),
                        );
                      },
                    ),
                    if (grant.deadline != null)
                      Text(
                        'Deadline: ${grant.deadline}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              grant.title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (grant.provider != null) ...[
              const SizedBox(height: 4),
              Text(
                'Offered by: ${grant.provider}',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
            if (grant.description != null) ...[
              const SizedBox(height: 8),
              Text(
                grant.description!,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  grant.amount != null
                      ? 'ETB ${grant.amount!.toStringAsFixed(0)}'
                      : 'ETB 1,000,000',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _applyForFunding(context, grant),
                  child: const Text('Apply Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyApplicationsTab() {
    return BlocBuilder<FundingBloc, FundingState>(
      builder: (context, state) {
        if (state is FundingMyApplicationsLoaded) {
          final apps = state.applications;
          if (apps.isEmpty) {
            return _buildEmptyState(
              'No Applications Submitted',
              'Apply for active funding opportunities to view your tracking pipeline here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    app.fundingId ?? 'Funding Application',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Applied: ${app.appliedAt ?? 'Recently'}'),
                      const SizedBox(height: 4),
                      Text('Status: ${app.status ?? 'UNDER_REVIEW'}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      app.status ?? 'REVIEW',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return _buildEmptyState(
          'No Applications Submitted',
          'Apply for active funding opportunities to view your tracking pipeline here.',
        );
      },
    );
  }

  void _applyForFunding(BuildContext context, Funding grant) {
    final companyController = TextEditingController();
    final projectController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Apply: ${grant.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  hintText: 'Company / Startup Name',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: projectController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Project Description & Objectives',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FundingBloc>().add(
                  ApplyForFunding(grant.id, {
                    'company': {'name': companyController.text.trim()},
                    'project': {'description': projectController.text.trim()},
                    'documents': {},
                  }),
                );
              },
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitPitchDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String? pickedFileName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Submit Pitch Deck'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Pitch Subject / Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Message to Investors / Executive Summary',
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final XTypeGroup typeGroup = const XTypeGroup(
                          label: 'pitch_decks',
                          extensions: ['pdf', 'pptx', 'ppt'],
                        );
                        final XFile? file = await openFile(
                          acceptedTypeGroups: [typeGroup],
                        );
                        if (file != null) {
                          setDialogState(() {
                            pickedFileName = file.name;
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          _showAwesomeSnackbar(
                            'File Error',
                            'Could not attach file: $e',
                            ContentType.failure,
                          );
                        }
                      }
                    },
                    icon: Icon(
                      pickedFileName != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                      color: pickedFileName != null ? Colors.green : null,
                    ),
                    label: Text(
                      pickedFileName ?? 'Attach Pitch Deck (PDF)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<PitchBloc>().add(
                      CreatePitch({
                        'subject': titleController.text.trim(),
                        'message': messageController.text.trim(),
                        'attachments': pickedFileName != null
                            ? [pickedFileName]
                            : [],
                      }),
                    );
                  },
                  child: const Text('Submit Pitch'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
