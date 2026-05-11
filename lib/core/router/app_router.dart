import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/injection.dart';
import '../services/secure_token_service.dart';
import '../widgets/main_shell.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/order/presentation/pages/create_order_page.dart';
import '../../features/order/presentation/pages/order_details_page.dart';
import '../../features/order/presentation/pages/order_tracking_page.dart';
import '../../features/order/presentation/pages/orders_history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/notification/presentation/pages/notifications_page.dart';
import '../../features/wallet/presentation/pages/recharge_page.dart';
import '../../features/wallet/presentation/pages/wallet_home_page.dart';
import '../../features/wallet/presentation/pages/jeko_recharge_page.dart';
import '../../features/wallet/presentation/pages/jeko_transaction_history_page.dart';
import '../../features/promo/presentation/pages/promotions_page.dart';
import '../../features/incoming/presentation/pages/incoming_orders_page.dart';
import '../../features/address/presentation/pages/addresses_page.dart';
import '../../features/settings/presentation/pages/accessibility_settings_page.dart';
import '../../features/tracking/presentation/bloc/live_tracking_bloc.dart';
import '../../features/tracking/presentation/pages/live_tracking_page.dart';
import '../../features/order/presentation/pages/order_chat_page.dart';
import '../../features/order/presentation/bloc/order_chat_bloc.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.matchedLocation;
      // Routes publiques accessibles sans authentification
      const publicRoutes = [
        Routes.splash,
        Routes.onboarding,
        Routes.login,
        Routes.register,
        Routes.otpVerification,
      ];
      final isPublic = publicRoutes.contains(location);
      final hasToken = getIt<SecureTokenService>().token != null;

      if (!hasToken && !isPublic) return Routes.login;
      return null;
    },
    routes: [
      // ── Routes hors shell (auth, splash, onboarding) ──────────────
      GoRoute(
        path: Routes.splash,
        name: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: Routes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
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
            confirmationMessage: extra?['confirmationMessage'] as String?,
          );
        },
      ),

      // ── Shell route avec BottomNavigationBar ──────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // ─ Onglet 0 : Accueil ─────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                name: Routes.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'create-order',
                    name: Routes.createOrder,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateOrderPage(),
                  ),
                  GoRoute(
                    path: 'promotions',
                    name: Routes.promotions,
                    builder: (context, state) => const PromotionsPage(),
                  ),
                ],
              ),
            ],
          ),

          // ─ Onglet 1 : Commandes ───────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.ordersHistory,
                name: Routes.ordersHistory,
                builder: (context, state) => const OrdersHistoryPage(),
              ),
            ],
          ),

          // ─ Onglet 2 : Wallet ──────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.wallet,
                name: Routes.wallet,
                builder: (context, state) => const WalletHomePage(),
                routes: [
                  GoRoute(
                    path: Routes.walletRecharge,
                    name: Routes.walletRecharge,
                    builder: (context, state) => const RechargePage(),
                  ),
                  GoRoute(
                    path: 'jeko-recharge',
                    name: Routes.jekoRecharge,
                    builder: (context, state) => const JekoRechargePage(),
                  ),
                  GoRoute(
                    path: 'jeko-history',
                    name: Routes.jekoHistory,
                    builder: (context, state) =>
                        const JekoTransactionHistoryPage(),
                  ),
                ],
              ),
            ],
          ),

          // ─ Onglet 3 : Profil ──────────────────────────────────────
          StatefulShellBranch(
            routes: [
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
                  GoRoute(
                    path: 'support',
                    name: Routes.support,
                    builder: (context, state) => const SupportPage(),
                  ),
                  GoRoute(
                    path: 'addresses',
                    name: Routes.addresses,
                    builder: (context, state) => const AddressesPage(),
                  ),
                  GoRoute(
                    path: 'accessibility',
                    name: Routes.accessibility,
                    builder: (context, state) =>
                        const AccessibilitySettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Routes plein écran (sans bottom bar) ──────────────────────
      GoRoute(
        path: '${Routes.orderDetails}/:orderId',
        name: Routes.orderDetails,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'];
          if (orderId == null || orderId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Commande introuvable')),
            );
          }
          return OrderDetailsPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: '${Routes.orderTracking}/:orderId',
        name: Routes.orderTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'];
          if (orderId == null || orderId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Commande introuvable')),
            );
          }
          return BlocProvider(
            create: (_) => getIt<LiveTrackingBloc>(),
            child: OrderTrackingPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: '${Routes.liveTracking}/:orderId',
        name: Routes.liveTracking,
        builder: (context, state) {
          final orderId =
              int.tryParse(state.pathParameters['orderId'] ?? '') ?? 0;
          if (orderId == 0) {
            return const Scaffold(
              body: Center(child: Text('Commande introuvable')),
            );
          }
          final trackingCode = state.uri.queryParameters['tracking'] ?? '';
          final courierName = state.uri.queryParameters['courierName'];
          final courierPhone = state.uri.queryParameters['courierPhone'];
          final pickupLat = double.tryParse(
            state.uri.queryParameters['pickupLat'] ?? '',
          );
          final pickupLng = double.tryParse(
            state.uri.queryParameters['pickupLng'] ?? '',
          );
          final deliveryLat = double.tryParse(
            state.uri.queryParameters['deliveryLat'] ?? '',
          );
          final deliveryLng = double.tryParse(
            state.uri.queryParameters['deliveryLng'] ?? '',
          );

          return BlocProvider(
            create: (_) => getIt<LiveTrackingBloc>(),
            child: LiveTrackingPage(
              orderId: orderId,
              trackingCode: trackingCode,
              courierName: courierName,
              courierPhone: courierPhone,
              pickupLatitude: pickupLat,
              pickupLongitude: pickupLng,
              deliveryLatitude: deliveryLat,
              deliveryLongitude: deliveryLng,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.incomingOrders,
        name: Routes.incomingOrders,
        builder: (context, state) => const IncomingOrdersPage(),
      ),
      GoRoute(
        path: '${Routes.orderChat}/:orderUuid',
        name: Routes.orderChat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final orderUuid = state.pathParameters['orderUuid'] ?? '';
          final courierName = state.uri.queryParameters['courierName'];
          return BlocProvider(
            create: (_) => getIt<OrderChatBloc>(),
            child: OrderChatPage(
              orderUuid: orderUuid,
              courierName: courierName,
            ),
          );
        },
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
  static const String wallet = '/wallet';
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
  static const String accessibility = 'accessibility';
  static const String incomingOrders = '/incoming-orders';
  static const String walletRecharge = 'recharge';
  static const String jekoRecharge = 'jeko-recharge';
  static const String jekoHistory = 'jeko-history';
  static const String orderChat = '/order-chat';
}
