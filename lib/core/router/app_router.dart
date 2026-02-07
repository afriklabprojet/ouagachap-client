import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/order/presentation/pages/create_order_page.dart';
import '../../features/order/presentation/pages/order_details_page.dart';
import '../../features/order/presentation/pages/order_tracking_page.dart';
import '../../features/order/presentation/pages/live_tracking_page.dart';
import '../../features/order/presentation/pages/orders_history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';
import '../../features/wallet/presentation/pages/recharge_page.dart';
import '../../features/wallet/presentation/pages/jeko_recharge_page.dart';
import '../../features/wallet/presentation/pages/jeko_transaction_history_page.dart';
import '../../features/promo/presentation/pages/promotions_page.dart';
import '../../features/incoming/presentation/pages/incoming_orders_page.dart';
import '../../features/address/presentation/pages/addresses_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      
      // Onboarding
      GoRoute(
        path: Routes.onboarding,
        name: Routes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      
      // Auth routes
      GoRoute(
        path: Routes.login,
        name: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        name: Routes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: Routes.otpVerification,
        name: Routes.otpVerification,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationPage(
            phoneNumber: extra?['phoneNumber'] ?? '',
            isLogin: extra?['isLogin'] ?? false,
          );
        },
      ),
      
      // Main app routes
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          // Create Order
          GoRoute(
            path: 'create-order',
            name: Routes.createOrder,
            builder: (context, state) => const CreateOrderPage(),
          ),
          // Recharge
          GoRoute(
            path: 'recharge',
            name: Routes.recharge,
            builder: (context, state) => const RechargePage(),
          ),
          // JEKO Recharge (Mobile Money)
          GoRoute(
            path: 'jeko-recharge',
            name: Routes.jekoRecharge,
            builder: (context, state) => const JekoRechargePage(),
          ),
          // JEKO Transaction History
          GoRoute(
            path: 'jeko-history',
            name: Routes.jekoHistory,
            builder: (context, state) => const JekoTransactionHistoryPage(),
          ),
          // Promotions
          GoRoute(
            path: 'promotions',
            name: Routes.promotions,
            builder: (context, state) => const PromotionsPage(),
          ),
        ],
      ),
      
      // Orders
      GoRoute(
        path: Routes.ordersHistory,
        name: Routes.ordersHistory,
        builder: (context, state) => const OrdersHistoryPage(),
      ),
      GoRoute(
        path: '${Routes.orderDetails}/:orderId',
        name: Routes.orderDetails,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailsPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: '${Routes.orderTracking}/:orderId',
        name: Routes.orderTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingPage(orderId: orderId);
        },
      ),
      // Suivi en temps réel
      GoRoute(
        path: '${Routes.liveTracking}/:orderId',
        name: Routes.liveTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return LiveTrackingPage(orderId: orderId);
        },
      ),
      
      // Profile
      GoRoute(
        path: Routes.profile,
        name: Routes.profile,
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            name: Routes.editProfile,
            builder: (context, state) => const EditProfilePage(),
          ),
          GoRoute(
            path: 'notifications',
            name: Routes.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          // Support route
          GoRoute(
            path: 'support',
            name: Routes.support,
            builder: (context, state) => const SupportPage(),
          ),
          // Adresses sauvegardées
          GoRoute(
            path: 'addresses',
            name: Routes.addresses,
            builder: (context, state) => const AddressesPage(),
          ),
        ],
      ),
      
      // Incoming orders (colis entrants)
      GoRoute(
        path: Routes.incomingOrders,
        name: Routes.incomingOrders,
        builder: (context, state) => const IncomingOrdersPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Route: ${state.uri.path}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}

abstract class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String createOrder = 'create-order';
  static const String recharge = 'recharge';
  static const String promotions = 'promotions';
  static const String ordersHistory = '/orders';
  static const String orderDetails = '/order';
  static const String orderTracking = '/tracking';
  static const String liveTracking = '/live-tracking';
  static const String profile = '/profile';
  static const String editProfile = 'edit';
  static const String notifications = 'notifications';
  static const String support = 'support';
  static const String addresses = 'addresses';
  static const String incomingOrders = '/incoming-orders';
  static const String jekoRecharge = 'jeko-recharge';
  static const String jekoHistory = 'jeko-history';
}
