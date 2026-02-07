import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/rating_dialog.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    context.read<OrderBloc>().add(
          GetOrderDetailsRequested(orderId: widget.orderId),
        );
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderBloc>().add(
                    CancelOrderRequested(orderId: order.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(Order order) {
    if (order.courier == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RatingDialog(
        courierName: order.courier!.name,
        onSubmit: (rating, review, tags) async {
          Navigator.pop(dialogContext);
          context.read<OrderBloc>().add(
                RateCourierRequested(
                  orderId: order.id,
                  rating: rating,
                  review: review,
                  tags: tags,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande annulée'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(Routes.ordersHistory);
        } else if (state is CourierRated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Merci pour votre évaluation !'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OrderLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Détails')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OrderDetailsLoaded) {
          return _buildContent(state.order);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Détails')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Erreur de chargement'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadOrderDetails,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(Order order) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${order.trackingNumber.substring(0, 8)}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.ordersHistory),
        ),
        actions: [
          if (order.isActive)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () =>
                  context.go('${Routes.orderTracking}/${order.id}'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            FadeInWidget(
              delay: const Duration(milliseconds: 100),
              child: _buildStatusCard(order),
            ),
            const SizedBox(height: 20),
            // Timeline
            SlideInWidget(
              delay: const Duration(milliseconds: 200),
              child: _buildTimeline(order),
            ),
            const SizedBox(height: 20),
            // Addresses
            SlideInWidget(
              delay: const Duration(milliseconds: 300),
              child: _buildAddressCard(order),
            ),
            const SizedBox(height: 20),
            // Courier info
            if (order.courier != null) ...[
              ScaleInWidget(
                delay: const Duration(milliseconds: 400),
                child: _buildCourierCard(order.courier!),
              ),
              const SizedBox(height: 20),
            ],
            // Price
            FadeInWidget(
              delay: const Duration(milliseconds: 500),
              child: _buildPriceCard(order),
            ),
            const SizedBox(height: 20),
            // Live Tracking Button
            if (order.canTrack)
              FadeInWidget(
                delay: const Duration(milliseconds: 550),
                child: _buildLiveTrackingButton(order),
              ),
            if (order.canTrack) const SizedBox(height: 12),
            // Actions
            if (order.canCancel) 
              FadeInWidget(
                delay: const Duration(milliseconds: 600),
                child: _buildCancelButton(order),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(order.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(order.status),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(order.status),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Commande créée',
            order.createdAt,
            true,
            isFirst: true,
          ),
          if (order.acceptedAt != null)
            _buildTimelineItem(
              'Acceptée par le coursier',
              order.acceptedAt!,
              true,
            ),
          if (order.pickedUpAt != null)
            _buildTimelineItem(
              'Colis récupéré',
              order.pickedUpAt!,
              true,
            ),
          if (order.deliveredAt != null)
            _buildTimelineItem(
              'Livré',
              order.deliveredAt!,
              true,
              isLast: true,
            ),
          if (order.cancelledAt != null)
            _buildTimelineItem(
              'Annulée',
              order.cancelledAt!,
              true,
              isLast: true,
              isCancelled: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    DateTime date,
    bool isCompleted, {
    bool isFirst = false,
    bool isLast = false,
    bool isCancelled = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCancelled
                    ? AppColors.error
                    : isCompleted
                        ? AppColors.success
                        : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.success : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isCancelled ? AppColors.error : null,
                ),
              ),
              Text(
                _formatDateTime(date),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adresses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildAddressItem(
            'Récupération',
            order.pickupAddress,
            AppColors.primary,
            Icons.location_on_outlined,
          ),
          const Divider(height: 24),
          _buildAddressItem(
            'Livraison',
            order.deliveryAddress,
            AppColors.secondary,
            Icons.location_on,
            subtitle: '${order.recipientName} - ${order.recipientPhone}',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(
    String label,
    String address,
    Color color,
    IconData icon, {
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourierCard(Courier courier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coursier',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  courier.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (courier.vehicleType != null)
                  Text(
                    courier.vehicleType!,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _callNumber(courier.phone),
            icon: const Icon(Icons.phone, color: AppColors.secondary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.secondary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Montant total',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.price.toInt()} FCFA',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Text(
            '${order.distance.toStringAsFixed(1)} km',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(Order order) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showCancelDialog(order),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
        child: const Text('Annuler la commande'),
      ),
    );
  }

  Widget _buildRatingButton(Order order) {
    if (!order.canRate) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showRatingDialog(order),
        icon: const Icon(Icons.star),
        label: const Text('Noter le coursier'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLiveTrackingButton(Order order) {
    if (!order.canTrack) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToLiveTracking(order),
        icon: const Icon(Icons.location_on),
        label: const Text('Suivre en direct'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _navigateToLiveTracking(Order order) {
    context.push(
      '${Routes.liveTracking}/${order.id}?tracking=${order.trackingNumber}',
    );
  }

  Widget _buildRatingDisplay(Order order) {
    if (order.courierRating == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Votre évaluation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < order.courierRating! ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 24,
              ),
            ),
          ),
          if (order.courierReview != null && order.courierReview!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              order.courierReview!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
        return AppColors.info;
      case OrderStatus.pickingUp:
        return AppColors.secondary;
      case OrderStatus.inTransit:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.pickingUp:
        return Icons.inventory;
      case OrderStatus.inTransit:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente d\'un coursier';
      case OrderStatus.accepted:
        return 'Un coursier a accepté votre commande';
      case OrderStatus.pickingUp:
        return 'Le coursier récupère votre colis';
      case OrderStatus.inTransit:
        return 'Votre colis est en route';
      case OrderStatus.delivered:
        return 'Votre colis a été livré';
      case OrderStatus.cancelled:
        return 'Cette commande a été annulée';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
