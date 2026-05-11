import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../services/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/notification/presentation/bloc/notification_state.dart';
import '../../features/order/presentation/bloc/order_bloc.dart';
import '../../features/order/presentation/bloc/order_state.dart';

/// Shell principale avec BottomNavigationBar persistante.
///
/// Les 4 onglets (Accueil, Commandes, Wallet, Profil) restent visibles
/// pendant la navigation interne, comme Gozem, Glovo, Yango.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bannière hors ligne
          ListenableBuilder(
            listenable: getIt<ConnectivityService>(),
            builder: (context, _) {
              final connectivity = getIt<ConnectivityService>();
              if (connectivity.isOnline) return const SizedBox.shrink();
              return MaterialBanner(
                content: const Text(
                  'Pas de connexion Internet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const Icon(Icons.wifi_off, color: Colors.white),
                backgroundColor: Colors.red.shade700,
                actions: [
                  TextButton(
                    onPressed: () => connectivity.checkConnectivity(),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, notifState) {
          int unreadCount = 0;
          if (notifState is NotificationLoaded) {
            unreadCount = notifState.unreadCount;
          }

          return BlocBuilder<OrderBloc, OrderState>(
            buildWhen: (prev, curr) {
              final prevCount = prev is OrdersLoaded
                  ? prev.orders.where((o) => o.isActive).length
                  : 0;
              final currCount = curr is OrdersLoaded
                  ? curr.orders.where((o) => o.isActive).length
                  : 0;
              return prevCount != currCount;
            },
            builder: (context, orderState) {
              final activeCount = orderState is OrdersLoaded
                  ? orderState.orders.where((o) => o.isActive).length
                  : 0;

              return NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                indicatorColor: AppColors.primary.withValues(alpha: 0.1),
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: AppColors.primary),
                    label: 'Accueil',
                  ),
                  NavigationDestination(
                    icon: activeCount > 0
                        ? Semantics(
                            label:
                                '$activeCount commande${activeCount > 1 ? 's' : ''} en cours',
                            child: Badge(
                              label: Text(
                                activeCount > 9 ? '9+' : '$activeCount',
                                style: const TextStyle(fontSize: 10),
                              ),
                              child: const Icon(Icons.receipt_long_outlined),
                            ),
                          )
                        : const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                    label: 'Commandes',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                    ),
                    label: 'Wallet',
                  ),
                  NavigationDestination(
                    icon: unreadCount > 0
                        ? Semantics(
                            label:
                                '$unreadCount notification${unreadCount > 1 ? 's' : ''} non lue${unreadCount > 1 ? 's' : ''}',
                            child: Badge(
                              label: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(fontSize: 10),
                              ),
                              child: const Icon(Icons.person_outline),
                            ),
                          )
                        : const Icon(Icons.person_outline),
                    selectedIcon: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                    label: 'Profil',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
