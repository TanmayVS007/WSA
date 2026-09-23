import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/onboarding_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/register_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/dashboard/presentation/screens/home_dashboard_screen.dart';
import '../features/device/presentation/screens/watch_status_screen.dart';
import '../features/emergency/presentation/screens/emergency_screen.dart';
import '../features/emergency/presentation/screens/emergency_details_screen.dart';
import '../features/emergency/presentation/screens/emergency_history_screen.dart';
import '../features/location/presentation/screens/map_screen.dart';
import '../features/contacts/presentation/screens/trusted_contacts_screen.dart';
import '../features/nearby_help/presentation/screens/nearby_help_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/privacy_safety_settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/watch-status',
        builder: (context, state) => const WatchStatusScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
      GoRoute(
        path: '/emergency/details/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? '';
          return EmergencyDetailsScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/emergency-history',
        builder: (context, state) => const EmergencyHistoryScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/contacts',
        builder: (context, state) => const TrustedContactsScreen(),
      ),
      GoRoute(
        path: '/nearby-help',
        builder: (context, state) => const NearbyHelpScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'privacy-safety',
            builder: (context, state) => const PrivacySafetySettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
