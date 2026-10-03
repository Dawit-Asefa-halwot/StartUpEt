import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/ecosystem/bloc/ecosystem_bloc.dart';
import '../../features/ecosystem/bloc/ecosystem_event.dart' hide EcosystemEvent;
import '../../features/ecosystem/bloc/ecosystem_state.dart';
import '../../features/event/bloc/event_bloc.dart';
import '../../features/event/bloc/event_event.dart';
import '../../features/event/bloc/event_state.dart';
import '../../models/ecosystem_event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<EventBloc>().add(const FetchEvents());
    context.read<EventBloc>().add(const FetchMyRegistrations());
    context.read<EcosystemBloc>().add(const FetchEcosystemSpaces());
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
        title: const Text('Events & Hub Spaces'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'My Passes'),
            Tab(text: 'Co-Working Spaces'),
          ],
        ),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventRegistered) {
            _showAwesomeSnackbar(
              'Registered!',
              'Your registration pass has been created successfully.',
              ContentType.success,
            );
            context.read<EventBloc>().add(const FetchMyRegistrations());
            context.read<EventBloc>().add(const FetchEvents());
          } else if (state is EventError) {
            _showAwesomeSnackbar('Notice', state.message, ContentType.failure);
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildEventsTab(),
            _buildMyPassesTab(),
            _buildSpacesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EventBloc>().add(const FetchEvents());
      },
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(
              child: SpinKitThreeBounce(color: AppColors.primary, size: 30),
            );
          }

          if (state is EventsLoaded) {
            final events = state.events;
            if (events.isEmpty) {
              return _buildEmptyState(
                'No Upcoming Events',
                'Check back soon for new ecosystem networking events.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildEventCard(events[index]);
              },
            );
          }

          return _buildEmptyState(
            'No Upcoming Events',
            'Check back soon for new ecosystem networking events.',
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EcosystemEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity( 0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.date != null && event.date!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.date!,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                if (event.location != null && event.location!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.location!,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showRegistrationDialog(event),
                    child: const Text('Register For Event'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRegistrationDialog(EcosystemEvent event) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final nameController = TextEditingController(
      text: user?.name ?? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
    );
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(
      text: user?.phone ?? '',
    );
    final companyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Register: ${event.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(
                    hintText: 'Startup / Organization Name',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
              ],
            ),
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
                context.read<EventBloc>().add(
                  RegisterForEvent(event.id, {
                    'fullName': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'organizationName': companyController.text.trim(),
                  }),
                );
              },
              child: const Text('Confirm Registration'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyPassesTab() {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventRegistrationsLoaded) {
          final passes = state.registrations;
          if (passes.isEmpty) {
            return _buildEmptyState(
              'No Event Passes Yet',
              'Register for upcoming ecosystem events to view your admission passes here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: passes.length,
            itemBuilder: (context, index) {
              final pass = passes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.qr_code, color: Colors.white),
                  ),
                  title: Text(
                    pass.eventTitle ?? 'Ecosystem Event Pass',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Attendee: ${pass.name ?? pass.email ?? 'Member'}'),
                      const SizedBox(height: 4),
                      Text('Status: ${pass.status ?? 'CONFIRMED'}'),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return _buildEmptyState(
          'No Event Passes Yet',
          'Register for upcoming ecosystem events to view your admission passes here.',
        );
      },
    );
  }

  Widget _buildSpacesTab() {
    return BlocBuilder<EcosystemBloc, EcosystemState>(
      builder: (context, state) {
        if (state is EcosystemLoading) {
          return const Center(
            child: SpinKitThreeBounce(color: AppColors.primary, size: 30),
          );
        }

        if (state is EcosystemSpacesLoaded) {
          final spaces = state.spaces;
          if (spaces.isEmpty) {
            return _buildEmptyState(
              'No Co-Working Spaces Available',
              'Innovation hubs and spaces will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final space = spaces[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        space.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        space.location ?? 'Addis Ababa, Ethiopia',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _bookSpace(space.name),
                        child: const Text('Book Desk / Space'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return _buildEmptyState(
          'No Co-Working Spaces Available',
          'Innovation hubs and spaces will appear here.',
        );
      },
    );
  }

  void _bookSpace(String spaceName) {
    final dateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Book $spaceName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select start date for workspace reservation:'),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.calendar_today),
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
                context.read<EcosystemBloc>().add(
                  CreateEcosystemBooking({
                    'spaceName': spaceName,
                    'startDate': dateController.text.trim(),
                  }),
                );
                _showAwesomeSnackbar(
                  'Booking Sent',
                  'Workspace reservation requested for $spaceName.',
                  ContentType.success,
                );
              },
              child: const Text('Confirm Booking'),
            ),
          ],
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
              Icons.event_available_outlined,
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
