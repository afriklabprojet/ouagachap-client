import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/status_mapper.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Each tab needs its own ScrollController to avoid shared scroll position
  late final List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollControllers = List.generate(3, (_) => ScrollController());
    for (final sc in _scrollControllers) {
      sc.addListener(() => _onScroll(sc));
    }
    _loadOrders();
  }

  void _loadOrders() {
    context.read<OrderBloc>().add(const GetOrdersRequested(refresh: true));
  }

  void _onScroll(ScrollController sc) {
    if (sc.position.pixels >= sc.position.maxScrollExtent - 200) {
      final state = context.read<OrderBloc>().state;
      if (state is OrdersLoaded && state.hasMore) {
        context.read<OrderBloc>().add(
          GetOrdersRequested(page: state.currentPage + 1),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final sc in _scrollControllers) {
      sc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
            Tab(text: 'Toutes'),
          ],
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        buildWhen: (p, c) {
          if (p is OrdersLoaded && c is OrdersLoaded) {
            return p.orders != c.orders || p.hasMore != c.hasMore;
          }
          return p.runtimeType != c.runtimeType;
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return SkeletonLoader(
              itemCount: 5,
              itemBuilder: (ctx, _) => const OrderCardSkeleton(),
            );
          }

          if (state is OrderError) {
            return AnimatedErrorWidget(
              title: 'Erreur',
              subtitle: state.message,
              retryText: 'Réessayer',
              onRetry: _loadOrders,
            );
          }

          if (state is OrdersLoaded) {
            final activeOrders = state.orders.where((o) => o.isActive).toList();
            final doneOrders = state.orders.where((o) => !o.isActive).toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(
                  activeOrders,
                  'Aucune commande en cours',
                  _scrollControllers[0],
                ),
                _buildOrderList(
                  doneOrders,
                  'Aucune commande terminée',
                  _scrollControllers[1],
                ),
                _buildOrderList(
                  state.orders,
                  'Aucune commande',
                  _scrollControllers[2],
                ),
              ],
            );
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }

  Widget _buildOrderList(
    List<Order> orders,
    String emptyMessage,
    ScrollController scrollController,
  ) {
    if (orders.isEmpty) {
      return AnimatedEmptyWidget(
        title: emptyMessage,
        subtitle: 'Créez une nouvelle livraison pour commencer',
        actionText: 'Nouvelle livraison',
        onAction: () => context.go('${Routes.home}/${Routes.createOrder}'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(const GetOrdersRequested(refresh: true));
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return SlideInWidget(
            delay: Duration(milliseconds: 50 * (index % 10)),
            beginOffset: const Offset(-0.3, 0),
            child: OrderCard(
              orderNumber: '#${order.trackingNumber.substring(0, 8)}',
              status: _getStatusLabel(order.status),
              statusColor: _getStatusColor(order.status),
              date: _formatDate(order.createdAt),
              pickupAddress: order.pickupAddress,
              deliveryAddress: order.deliveryAddress,
              amount: '${order.price.toInt()} FCFA',
              onTap: () => context.go('${Routes.orderDetails}/${order.id}'),
              onTrack: order.isActive
                  ? () => context.go('${Routes.orderTracking}/${order.id}')
                  : null,
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) =>
      OrderStatusMapper.getColor(status);

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.accepted:
        return 'Acceptée';
      case OrderStatus.pickingUp:
        return 'Récupération';
      case OrderStatus.inTransit:
        return 'En cours';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
