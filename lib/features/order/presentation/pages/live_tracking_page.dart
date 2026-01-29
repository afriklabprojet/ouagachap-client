import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/realtime_tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';

class LiveTrackingPage extends StatefulWidget {
  final String orderId;
  
  const LiveTrackingPage({super.key, required this.orderId});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> 
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  final RealTimeTrackingService _trackingService = RealTimeTrackingService();
  
  // Subscriptions
  StreamSubscription<DeliveryTrackingInfo>? _trackingSubscription;
  StreamSubscription<CourierPosition>? _positionSubscription;
  
  // State
  DeliveryTrackingInfo? _trackingInfo;
  CourierPosition? _courierPosition;
  LatLng? _lastCourierPosition;
  bool _isLoading = true;
  bool _followCourier = true;
  
  // Map elements
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  
  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Route history pour tracer le chemin parcouru
  List<LatLng> _courierRouteHistory = [];

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startTracking();
  }
  
  void _initAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  void _startTracking() {
    _trackingService.startTracking(widget.orderId);
    
    _trackingSubscription = _trackingService.trackingStream.listen((info) {
      setState(() {
        _trackingInfo = info;
        _isLoading = false;
        _updateMapElements();
      });
    });
    
    _positionSubscription = _trackingService.courierPositionStream.listen((position) {
      setState(() {
        _courierPosition = position;
        
        // Ajouter à l'historique de route
        if (_lastCourierPosition == null || 
            _calculateDistance(_lastCourierPosition!, position.latLng) > 0.01) {
          _courierRouteHistory.add(position.latLng);
          _lastCourierPosition = position.latLng;
        }
        
        _updateCourierMarker();
        
        // Suivre le coursier si activé
        if (_followCourier && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(position.latLng),
          );
        }
      });
    });
  }
  
  double _calculateDistance(LatLng p1, LatLng p2) {
    return ((p1.latitude - p2.latitude).abs() + 
            (p1.longitude - p2.longitude).abs());
  }
  
  void _updateMapElements() {
    if (_trackingInfo == null) return;
    
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final circles = <Circle>{};
    
    // Marker de récupération
    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: _trackingInfo!.pickupLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: 'Point de récupération',
        snippet: _trackingInfo!.pickupAddress,
      ),
    ));
    
    // Marker de livraison
    markers.add(Marker(
      markerId: const MarkerId('delivery'),
      position: _trackingInfo!.deliveryLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Point de livraison',
        snippet: _trackingInfo!.deliveryAddress,
      ),
    ));
    
    // Route prévue (en pointillés)
    if (_trackingInfo!.routePolyline.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('planned_route'),
        points: _trackingInfo!.routePolyline,
        color: Colors.blue.withOpacity(0.4),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    } else {
      // Route simple si pas de polyline
      polylines.add(Polyline(
        polylineId: const PolylineId('simple_route'),
        points: [
          _trackingInfo!.pickupLocation,
          _trackingInfo!.deliveryLocation,
        ],
        color: Colors.blue.withOpacity(0.4),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    }
    
    // Chemin parcouru par le coursier (ligne pleine)
    if (_courierRouteHistory.length >= 2) {
      polylines.add(Polyline(
        polylineId: const PolylineId('courier_path'),
        points: _courierRouteHistory,
        color: AppColors.primary,
        width: 5,
      ));
    }
    
    // Cercle de destination (zone d'arrivée)
    circles.add(Circle(
      circleId: const CircleId('delivery_zone'),
      center: _trackingInfo!.deliveryLocation,
      radius: 50, // 50 mètres
      fillColor: AppColors.success.withOpacity(0.1),
      strokeColor: AppColors.success,
      strokeWidth: 2,
    ));
    
    setState(() {
      _markers = markers;
      _polylines = polylines;
      _circles = circles;
    });
  }
  
  void _updateCourierMarker() {
    if (_courierPosition == null) return;
    
    // Supprimer l'ancien marker coursier et ajouter le nouveau
    _markers.removeWhere((m) => m.markerId.value == 'courier');
    
    _markers.add(Marker(
      markerId: const MarkerId('courier'),
      position: _courierPosition!.latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      rotation: _courierPosition!.heading ?? 0,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(
        title: _courierPosition!.courierName,
        snippet: _courierPosition!.speed != null 
            ? '${_courierPosition!.speed!.toInt()} km/h'
            : 'En route',
      ),
    ));
    
    setState(() {});
  }
  
  void _fitMapToBounds() {
    if (_mapController == null || _trackingInfo == null) return;
    
    final points = <LatLng>[
      _trackingInfo!.pickupLocation,
      _trackingInfo!.deliveryLocation,
    ];
    
    if (_courierPosition != null) {
      points.add(_courierPosition!.latLng);
    }
    
    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }
  
  Future<void> _callCourier() async {
    if (_courierPosition?.courierPhone == null) return;
    
    final uri = Uri.parse('tel:${_courierPosition!.courierPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
  
  Future<void> _messageCourier() async {
    if (_courierPosition?.courierPhone == null) return;
    
    final uri = Uri.parse('sms:${_courierPosition!.courierPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _positionSubscription?.cancel();
    _trackingService.stopTracking();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? _buildLoadingView()
          : _trackingInfo == null 
              ? _buildErrorView()
              : _buildTrackingView(),
    );
  }
  
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAnimation.delivery(width: 200),
          const SizedBox(height: 16),
          const Text(
            'Chargement du suivi...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return AnimatedErrorWidget(
      title: 'Erreur',
      message: 'Impossible de charger le suivi',
      retryText: 'Réessayer',
      onRetry: () {
        setState(() => _isLoading = true);
        _startTracking();
      },
    );
  }
  
  Widget _buildTrackingView() {
    return Stack(
      children: [
        // Carte Google Maps
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _trackingInfo!.pickupLocation,
            zoom: 14,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            Future.delayed(const Duration(milliseconds: 500), _fitMapToBounds);
          },
          markers: _markers,
          polylines: _polylines,
          circles: _circles,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        
        // Header avec statut
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildHeader(),
        ),
        
        // Boutons de contrôle
        Positioned(
          top: MediaQuery.of(context).padding.top + 120,
          right: 16,
          child: Column(
            children: [
              // Suivre le coursier
              FloatingActionButton.small(
                heroTag: 'follow',
                backgroundColor: _followCourier ? AppColors.primary : Colors.white,
                onPressed: () {
                  setState(() => _followCourier = !_followCourier);
                  if (_followCourier && _courierPosition != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(_courierPosition!.latLng),
                    );
                  }
                },
                child: Icon(
                  Icons.gps_fixed,
                  color: _followCourier ? Colors.white : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              // Voir tout le trajet
              FloatingActionButton.small(
                heroTag: 'fit',
                backgroundColor: Colors.white,
                onPressed: _fitMapToBounds,
                child: Icon(Icons.zoom_out_map, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        
        // Info coursier temps réel
        if (_courierPosition != null)
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 120,
            child: _buildCourierSpeedCard(),
          ),
        
        // Bottom sheet avec infos détaillées
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomSheet(),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0),
          ],
        ),
      ),
      child: Row(
        children: [
          // Bouton retour
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          // Statut de la commande
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _trackingInfo!.isCourierOnRoute 
                            ? _pulseAnimation.value 
                            : 1.0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getStatusColor(_trackingInfo!.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _trackingInfo!.statusLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (_trackingInfo!.estimatedMinutes != null)
                          Text(
                            'Arrivée dans ~${_trackingInfo!.estimatedMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Indicateur temps réel
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCourierSpeedCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_courierPosition!.speed?.toInt() ?? 0}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Text(
            'km/h',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomSheet() {
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
      child: SafeArea(
        top: false,
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
            
            // Barre de progression
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildProgressBar(),
            ),
            
            // Info coursier
            if (_courierPosition != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCourierInfo(),
              ),
            
            // Info livraison
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildDeliveryInfo(),
            ),
            
            // Boutons d'action
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  if (_courierPosition != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _callCourier,
                        icon: const Icon(Icons.phone),
                        label: const Text('Appeler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _messageCourier,
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                      ),
                    ),
                  ] else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Recherche de coursier...'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressBar() {
    final progress = _trackingInfo!.progressPercent;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProgressStep(
              icon: Icons.store,
              label: 'Récupération',
              isActive: progress >= 0.25,
              isCompleted: progress >= 0.5,
            ),
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: progress >= 0.5 ? AppColors.success : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildProgressStep(
              icon: Icons.local_shipping,
              label: 'En route',
              isActive: progress >= 0.5,
              isCompleted: progress >= 0.75,
            ),
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: progress >= 1.0 ? AppColors.success : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildProgressStep(
              icon: Icons.check_circle,
              label: 'Livré',
              isActive: progress >= 0.75,
              isCompleted: progress >= 1.0,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProgressStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppColors.success 
                : isActive 
                    ? AppColors.primary 
                    : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourierInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Photo coursier
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _courierPosition!.courierPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _courierPosition!.courierPhoto!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(width: 12),
          // Infos coursier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _courierPosition!.courierName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_courierPosition!.vehicleType != null)
                  Row(
                    children: [
                      Icon(
                        _getVehicleIcon(_courierPosition!.vehicleType!),
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _courierPosition!.vehicleType!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_courierPosition!.vehiclePlate != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _courierPosition!.vehiclePlate!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          // Rating (fictif pour l'instant)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDeliveryInfo() {
    return Column(
      children: [
        // Point de récupération
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade200, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Récupération',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _trackingInfo!.pickupAddress,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Ligne de connexion
        Container(
          margin: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Container(
                width: 2,
                height: 20,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
        // Point de livraison
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Livraison',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _trackingInfo!.deliveryAddress,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Distance et temps estimé
            if (_trackingInfo!.estimatedDistance != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_trackingInfo!.estimatedDistance!.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (_trackingInfo!.estimatedMinutes != null)
                    Text(
                      '~${_trackingInfo!.estimatedMinutes} min',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
  
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'moto':
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'voiture':
      case 'car':
        return Icons.directions_car;
      case 'vélo':
      case 'bicycle':
        return Icons.pedal_bike;
      default:
        return Icons.local_shipping;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return AppColors.primary;
      case 'in_transit':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
