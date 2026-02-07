import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/cards.dart';
import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  GoogleMapController? _mapController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    // Refresh toutes les 10 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadOrder();
    });
  }

  void _loadOrder() {
    context.read<OrderBloc>().add(
          GetOrderDetailsRequested(orderId: widget.orderId),
        );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(Order order) {
    final markers = <Marker>{};

    // Pickup marker
    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(order.pickupLatitude, order.pickupLongitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: 'Récupération',
        snippet: order.pickupAddress,
      ),
    ));

    // Delivery marker
    markers.add(Marker(
      markerId: const MarkerId('delivery'),
      position: LatLng(order.deliveryLatitude, order.deliveryLongitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Livraison',
        snippet: order.deliveryAddress,
      ),
    ));

    // Courier marker
    if (order.courier?.currentLatitude != null &&
        order.courier?.currentLongitude != null) {
      markers.add(Marker(
        markerId: const MarkerId('courier'),
        position: LatLng(
          order.courier!.currentLatitude!,
          order.courier!.currentLongitude!,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Coursier',
          snippet: order.courier!.name,
        ),
      ));
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(Order order) {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(order.pickupLatitude, order.pickupLongitude),
          LatLng(order.deliveryLatitude, order.deliveryLongitude),
        ],
        color: AppColors.primary,
        width: 4,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      ),
    };
  }

  void _fitMapToBounds(Order order) {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        order.pickupLatitude < order.deliveryLatitude
            ? order.pickupLatitude
            : order.deliveryLatitude,
        order.pickupLongitude < order.deliveryLongitude
            ? order.pickupLongitude
            : order.deliveryLongitude,
      ),
      northeast: LatLng(
        order.pickupLatitude > order.deliveryLatitude
            ? order.pickupLatitude
            : order.deliveryLatitude,
        order.pickupLongitude > order.deliveryLongitude
            ? order.pickupLongitude
            : order.deliveryLongitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  Future<void> _callCourier(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Suivi')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OrderDetailsLoaded || state is OrderTracking) {
          final order = state is OrderDetailsLoaded
              ? state.order
              : (state as OrderTracking).order;
          return _buildContent(order);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Suivi')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Erreur de chargement'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadOrder,
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
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(order.pickupLatitude, order.pickupLongitude),
              zoom: 14,
            ),
            markers: _buildMarkers(order),
            polylines: _buildPolylines(order),
            onMapCreated: (controller) {
              _mapController = controller;
              Future.delayed(const Duration(milliseconds: 500), () {
                _fitMapToBounds(order);
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.go(Routes.home),
              ),
            ),
          ),
          // Fit to bounds button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.center_focus_strong, color: Colors.black),
                onPressed: () => _fitMapToBounds(order),
              ),
            ),
          ),
          // Bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(order),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(Order order) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Status
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(order.status),
                    color: _getStatusColor(order.status),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusDescription(order.status),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.price.toInt()} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${order.distance.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress bar
          if (order.isActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProgressBar(order.status),
            ),
          const SizedBox(height: 16),
          // Courier info
          if (order.courier != null)
            SlideInWidget(
              beginOffset: const Offset(0, 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CourierCard(
                  name: order.courier!.name,
                  vehicleInfo: order.courier!.vehicleType,
                  rating: order.courier!.rating?.toDouble(),
                  onCall: () => _callCourier(order.courier!.phone),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // View details button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.go('${Routes.orderDetails}/${order.id}'),
                    child: const Text('Voir détails'),
                  ),
                ),
                if (order.canCancel) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showCancelDialog(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildProgressBar(OrderStatus status) {
    final steps = [
      OrderStatus.pending,
      OrderStatus.accepted,
      OrderStatus.pickingUp,
      OrderStatus.inTransit,
      OrderStatus.delivered,
    ];

    final currentIndex = steps.indexOf(status);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: 4,
              color: stepIndex < currentIndex
                  ? AppColors.success
                  : Colors.grey[300],
            ),
          );
        } else {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= currentIndex;
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.success : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : null,
          );
        }
      }),
    );
  }

  void _showCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content:
            const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<OrderBloc>().add(
                    CancelOrderRequested(orderId: order.id),
                  );
              this.context.go(Routes.home);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Oui, annuler'),
          ),
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
        return 'Recherche d\'un coursier...';
      case OrderStatus.accepted:
        return 'Le coursier arrive pour récupérer le colis';
      case OrderStatus.pickingUp:
        return 'Récupération du colis en cours';
      case OrderStatus.inTransit:
        return 'Livraison en cours';
      case OrderStatus.delivered:
        return 'Colis livré avec succès !';
      case OrderStatus.cancelled:
        return 'Commande annulée';
    }
  }
}
