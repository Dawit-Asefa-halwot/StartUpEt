import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/app_colors.dart';
import '../../../../presentation/screens/applications_screen.dart';
import '../../../../presentation/screens/certifications_screen.dart';
import '../../../../presentation/screens/settings_screen.dart';
import '../../../../presentation/widgets/startup_dashboard_view.dart';
import '../../../application/bloc/application_bloc.dart';
import '../../../application/bloc/application_event.dart';
import '../../../startup/bloc/startup_bloc.dart';
import '../../../startup/bloc/startup_event.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StartupBloc>().add(const FetchStartupStatus());
        context.read<ApplicationBloc>().add(const FetchApplications());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildGlassTabItem(
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.mutedText,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 4),
            // Active Tab Orange Underline (16x3px)
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        if (user == null) return const SizedBox();

        final List<Widget> pages = [
          StartupDashboardView(
            user: user,
            onNavigateTab: (index) {
              setState(() {
                _currentIndex = index;
                _tabController.animateTo(index);
              });
            },
          ),
          const ApplicationsScreen(),
          const CertificationsScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Tab View Content
              TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),

              // Soft blurred color glows behind the nav bar
              Positioned(
                left: 20,
                bottom: bottomInset + 10,
                child: Container(
                  width: 130,
                  height: 40,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x6108737C), // Teal rgba(8,115,124,0.38)
                        blurRadius: 36,
                        spreadRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: bottomInset + 10,
                child: Container(
                  width: 130,
                  height: 40,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x6BF7A03A), // Orange rgba(247,160,58,0.42)
                        blurRadius: 36,
                        spreadRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // Floating Frosted Glass Bottom Navigation Bar
              Positioned(
                left: 12,
                right: 12,
                bottom: bottomInset + 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x8CFFFFFF), // rgba(255,255,255,0.55)
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xBFFFFFFF), // rgba(255,255,255,0.75)
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2E08737C), // rgba(8,115,124,0.18)
                        blurRadius: 32,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            _buildGlassTabItem(
                              0,
                              Icons.grid_view_outlined,
                              'Home',
                            ),
                            _buildGlassTabItem(
                              1,
                              Icons.description_outlined,
                              'Applications',
                            ),
                            _buildGlassTabItem(
                              2,
                              Icons.workspace_premium_outlined,
                              'Certificates',
                            ),
                            _buildGlassTabItem(
                              3,
                              Icons.settings_outlined,
                              'Settings',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
