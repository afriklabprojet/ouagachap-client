import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/incoming_order.dart';
import '../bloc/incoming_order_bloc.dart';
import '../bloc/incoming_order_event.dart';
import '../bloc/incoming_order_state.dart';

class IncomingOrdersPage extends StatefulWidget {
  const IncomingOrdersPage({super.key});

  @override
  State<IncomingOrdersPage> createState() => _IncomingOrdersPageState();
}

class _IncomingOrdersPageState extends State<IncomingOrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<IncomingOrderBloc>().add(const LoadIncomingOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colis à recevoir'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<IncomingOrderBloc>().add(
                const RefreshIncomingOrders(),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<IncomingOrderBloc, IncomingOrderState>(
        listener: (context, state) {
          if (state is IncomingOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IncomingOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IncomingOrderLoaded) {
            return _buildContent(state);
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildContent(IncomingOrderLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<IncomingOrderBloc>().add(const RefreshIncomingOrders());
      },
      child: CustomScrollView(
        slivers: [
          // Stats cards
          SliverToBoxAdapter(child: _buildStatsCards(state.stats)),

          // Filters
          SliverToBoxAdapter(child: _buildFilters(state.activeFilter)),

          // Orders list
          if (state.orders.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildOrderCard(state.orders[index]),
                  childCount: state.orders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(IncomingOrderStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '⏳',
              'En attente',
              stats.pending.toString(),
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '🚚',
              'En route',
              stats.inTransit.toString(),
              AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '✅',
              'Reçus',
              stats.delivered.toString(),
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFilters(String? activeFilter) {
    final filters = [
      {'value': null, 'label': 'Tous'},
      {'value': 'pending', 'label': 'En attente'},
      {'value': 'accepted', 'label': 'Acceptés'},
      {'value': 'picked_up', 'label': 'En cours'},
      {'value': 'delivered', 'label': 'Livrés'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = activeFilter == filter['value'];

          return FilterChip(
            label: Text(filter['label']!),
            selected: isActive,
            onSelected: (selected) {
              context.read<IncomingOrderBloc>().add(
                LoadIncomingOrders(status: filter['value']),
              );
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(IncomingOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  _buildStatusBadge(order.status, order.statusLabel),
                ],
              ),

              const Divider(height: 20),

              // Expéditeur
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'De: ${order.senderName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Adresse
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.dropoffAddress,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (order.packageDescription != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.packageDescription!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  if (order.canTrack)
                    TextButton.icon(
                      onPressed: () => _openTracking(order),
                      icon: const Icon(Icons.location_searching, size: 18),
                      label: const Text('Suivre'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'accepted':
      case 'picked_up':
        color = AppColors.info;
        break;
      case 'delivered':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun colis à recevoir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quand quelqu\'un vous enverra un colis,\nil apparaîtra ici.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openOrderDetails(IncomingOrder order) {
    context.pushNamed(
      Routes.orderDetails,
      pathParameters: {'orderId': order.id},
    );
  }

  void _openTracking(IncomingOrder order) {
    context.pushNamed(
      Routes.liveTracking,
      pathParameters: {'orderId': order.id},
    );
  }
}
