import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/app_colors.dart';
import 'features/application/bloc/application_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/certificate/bloc/certificate_bloc.dart';
import 'features/cron/bloc/cron_bloc.dart';
import 'features/ecosystem/bloc/ecosystem_bloc.dart';
import 'features/event/bloc/event_bloc.dart';
import 'features/file/bloc/file_bloc.dart';
import 'features/funding/bloc/funding_bloc.dart';
import 'features/notification/bloc/notification_bloc.dart';
import 'features/pitch/bloc/pitch_bloc.dart';
import 'features/startup/bloc/startup_bloc.dart';
import 'features/verification/bloc/verification_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();

  const storage = FlutterSecureStorage();
  final apiKey = await storage.read(key: 'api_key');
  final hasToken = apiKey != null && apiKey.isNotEmpty;

  runApp(StartupetApp(hasStoredToken: hasToken));
}

class StartupetApp extends StatelessWidget {
  final bool hasStoredToken;

  const StartupetApp({super.key, bool? isAuthenticated, bool? hasStoredToken})
    : hasStoredToken = hasStoredToken ?? isAuthenticated ?? false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final bloc = di.sl<AuthBloc>();
            if (hasStoredToken) {
              bloc.add(const AuthCheckRequested());
            }
            return bloc;
          },
        ),
        BlocProvider<StartupBloc>(
          lazy: true,
          create: (context) => di.sl<StartupBloc>(),
        ),
        BlocProvider<ApplicationBloc>(
          lazy: true,
          create: (context) => di.sl<ApplicationBloc>(),
        ),
        BlocProvider<FundingBloc>(
          lazy: true,
          create: (context) => di.sl<FundingBloc>(),
        ),
        BlocProvider<EventBloc>(
          lazy: true,
          create: (context) => di.sl<EventBloc>(),
        ),
        BlocProvider<EcosystemBloc>(
          lazy: true,
          create: (context) => di.sl<EcosystemBloc>(),
        ),
        BlocProvider<CertificateBloc>(
          lazy: true,
          create: (context) => di.sl<CertificateBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          lazy: true,
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<VerificationBloc>(
          lazy: true,
          create: (context) => di.sl<VerificationBloc>(),
        ),
        BlocProvider<PitchBloc>(
          lazy: true,
          create: (context) => di.sl<PitchBloc>(),
        ),
        BlocProvider<FileBloc>(
          lazy: true,
          create: (context) => di.sl<FileBloc>(),
        ),
        BlocProvider<CronBloc>(
          lazy: true,
          create: (context) => di.sl<CronBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'StartupEt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: AuthGate(hasStoredToken: hasStoredToken),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  final bool hasStoredToken;

  const AuthGate({super.key, this.hasStoredToken = false});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late bool _isCheckingInitialAuth;

  @override
  void initState() {
    super.initState();
    _isCheckingInitialAuth = widget.hasStoredToken;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthAuthenticated || current is AuthUnauthenticated;
      },
      listener: (context, state) {
        if (_isCheckingInitialAuth) {
          setState(() {
            _isCheckingInitialAuth = false;
          });
        }
      },
      buildWhen: (previous, current) {
        return current is AuthAuthenticated ||
            current is AuthUnauthenticated ||
            current is AuthInitial;
      },
      builder: (context, state) {
        Widget child;
        if (_isCheckingInitialAuth && (state is AuthLoading || state is AuthInitial)) {
          child = const InAppLoadingSplashScreen(key: ValueKey('splash'));
        } else if (state is AuthAuthenticated) {
          child = const HomeScreen(key: ValueKey('home'));
        } else {
          child = const LoginScreen(key: ValueKey('login'));
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
