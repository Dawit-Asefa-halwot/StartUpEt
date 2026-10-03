import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

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

  Widget _buildTabItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return Tab(
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity( 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? Colors.tealAccent : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          body: BottomBar(
            showIcon: false,
            width: MediaQuery.of(context).size.width * 0.92,
            borderRadius: BorderRadius.circular(30),
            offset: 16,
            barDecoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            body: (context, controller) => TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(),
                indicatorColor: Colors.transparent,
                indicatorWeight: 0,
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  _buildTabItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard,
                    'Dashboard',
                  ),
                  _buildTabItem(
                    1,
                    Icons.assignment_outlined,
                    Icons.assignment,
                    'Application',
                  ),
                  _buildTabItem(
                    2,
                    Icons.workspace_premium_outlined,
                    Icons.workspace_premium,
                    'Certifications',
                  ),
                  _buildTabItem(
                    3,
                    Icons.settings_outlined,
                    Icons.settings,
                    'Settings',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
