import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/ecosystem/bloc/ecosystem_bloc.dart';
import '../../features/ecosystem/bloc/ecosystem_event.dart' hide EcosystemEvent;
import '../../features/ecosystem/bloc/ecosystem_state.dart';
import '../widgets/notifications_bottom_sheet.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showAwesomeSnackbar(
    BuildContext context,
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
    return BlocListener<EcosystemBloc, EcosystemState>(
      listener: (context, state) {
        if (state is EcosystemApplicationSubmitted) {
          _showAwesomeSnackbar(
            context,
            'Application Submitted!',
            'Your Ecosystem Builder application is now under official review.',
            ContentType.success,
          );
        } else if (state is EcosystemError) {
          _showAwesomeSnackbar(
            context,
            'Submission Notice',
            state.message,
            ContentType.failure,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings & Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;

            final userName = user?.name ?? user?.email ?? 'User Profile';
            final email = user?.email ?? 'Not available';
            final role = user?.role ?? 'USER';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Banner Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primary,
                            backgroundImage:
                                user?.image != null && user!.image!.isNotEmpty
                                    ? NetworkImage(user.image!)
                                    : null,
                            child: (user?.image == null || user!.image!.isEmpty)
                                ? Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : 'L',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(
                                      0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    role,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Edit Profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(user: user),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Account Preferences',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Edit Profile Option
                  _settingsOptionTile(
                    context,
                    title: 'Edit Profile Information',
                    subtitle: 'Update name, phone number, location & avatar',
                    icon: Icons.person_outline,
                    iconColor: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(user: user),
                        ),
                      );
                    },
                  ),

                  // Notifications Option
                  _settingsOptionTile(
                    context,
                    title: 'Notifications & Alerts',
                    subtitle: 'System notices, grant updates, SSE stream',
                    icon: Icons.notifications_active,
                    iconColor: Colors.amber.shade800,
                    onTap: () => NotificationsBottomSheet.show(context),
                  ),

                  // Ecosystem Builder Application Option
                  _settingsOptionTile(
                    context,
                    title: 'Apply as Ecosystem Builder',
                    subtitle: 'Incubator, accelerator & hub manager application',
                    icon: Icons.business_center,
                    iconColor: Colors.teal,
                    onTap: () => _showEcosystemBuilderDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _settingsOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showEcosystemBuilderDialog(BuildContext context) {
    final orgNameController = TextEditingController();
    final typeController = TextEditingController();
    final websiteController = TextEditingController();
    final bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Ecosystem Builder Application'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orgNameController,
                  decoration: const InputDecoration(
                    hintText: 'Organization Name',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    hintText: 'Builder Type (e.g. Incubator, Accelerator, Hub)',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: websiteController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: 'Official Website / Portal URL',
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Organization Mission & Program Overview',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
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
                context.read<EcosystemBloc>().add(
                  SubmitEcosystemApplication({
                    'organizationName': orgNameController.text.trim(),
                    'builderType': typeController.text.trim(),
                    'website': websiteController.text.trim(),
                    'description': bioController.text.trim(),
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout Confirmation'),
          content: const Text(
            'Are you sure you want to log out of your StartupET account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const AuthLogout());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
