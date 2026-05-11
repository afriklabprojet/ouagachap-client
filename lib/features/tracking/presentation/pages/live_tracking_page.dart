import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/live_tracking_bloc.dart';
import '../bloc/live_tracking_event.dart';
import '../bloc/live_tracking_state.dart';

/// Page de suivi en temps réel avec carte
class LiveTrackingPage extends StatefulWidget {
  final int orderId;
  final String trackingCode;
  final String? courierName;
  final String? courierPhone;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  const LiveTrackingPage({
    super.key,
    required this.orderId,
    required this.trackingCode,
    this.courierName,
    this.courierPhone,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage>
    with WidgetsBindingObserver {
  final Completer<GoogleMapController> _mapController = Completer();
  final _markersNotifier = ValueNotifier<Set<Marker>>({});
  final _polylinesNotifier = ValueNotifier<Set<Polyline>>({});
  late final BitmapDescriptor _courierIcon;

  // Position par défaut : Ouagadougou
  static const LatLng _defaultPosition = LatLng(12.3714, -1.5197);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Mettre en cache l'icône du coursier (créée une seule fois)
    _courierIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    );

    // Démarrer le suivi
    context.read<LiveTrackingBloc>().add(
      StartTracking(orderId: widget.orderId, trackingCode: widget.trackingCode),
    );

    // Initialiser les marqueurs statiques
    _initStaticMarkers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _markersNotifier.dispose();
    _polylinesNotifier.dispose();
    // Disposer le GoogleMapController pour éviter les fuites mémoire
    _mapController.future.then((c) => c.dispose()).catchError((_) {});
    context.read<LiveTrackingBloc>().add(const StopTracking());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<LiveTrackingBloc>().add(const ReconnectTracking());
    }
  }

  void _initStaticMarkers() {
    final markers = <Marker>{};

    // Marqueur point de récupération
    if (widget.pickupLatitude != null && widget.pickupLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.pickupLatitude!, widget.pickupLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Point de récupération'),
        ),
      );
    }

    // Marqueur point de livraison
    if (widget.deliveryLatitude != null && widget.deliveryLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(widget.deliveryLatitude!, widget.deliveryLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Point de livraison'),
        ),
      );
    }

    _markersNotifier.value = markers;
  }

  void _updateCourierMarker(LiveTrackingState state) {
    if (!state.hasCourierLocation) return;

    final courierPosition = LatLng(
      state.courierLatitude!,
      state.courierLongitude!,
    );

    // Mettre à jour les marqueurs
    final updatedMarkers = _markersNotifier.value
        .where((m) => m.markerId.value != 'courier')
        .toSet();
    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('courier'),
        position: courierPosition,
        icon: _courierIcon,
        infoWindow: InfoWindow(
          title: widget.courierName ?? 'Coursier',
          snippet: state.statusMessage,
        ),
        rotation: state.courierHeading ?? 0,
        flat: true,
      ),
    );

    // Mettre à jour la polyline du trajet
    if (state.routeHistory.isNotEmpty) {
      final points = state.routeHistory
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      _polylinesNotifier.value = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: AppColors.primary,
          width: 4,
        ),
      };
    }

    _markersNotifier.value = updatedMarkers;

    // Centrer la carte sur le coursier
    _animateCameraToPosition(courierPosition);
  }

  Future<void> _animateCameraToPosition(LatLng position) async {
    if (!mounted) return;
    final controller = await _mapController.future;
    if (!mounted) return;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _fitAllMarkers() async {
    if (_markersNotifier.value.length < 2 || !mounted) return;

    final controller = await _mapController.future;
    if (!mounted) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final marker in _markersNotifier.value) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) {
        minLng = marker.position.longitude;
      }
      if (marker.position.longitude > maxLng) {
        maxLng = marker.position.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _callCourier() async {
    if (widget.courierPhone == null) return;
    final uri = Uri.parse('tel:${widget.courierPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LiveTrackingBloc, LiveTrackingState>(
        listenWhen: (p, c) =>
            p.courierLatitude != c.courierLatitude ||
            p.courierLongitude != c.courierLongitude ||
            p.routeHistory.length != c.routeHistory.length ||
            p.errorMessage != c.errorMessage,
        buildWhen: (p, c) =>
            p.connectionStatus != c.connectionStatus ||
            p.hasCourierLocation != c.hasCourierLocation ||
            p.statusMessage != c.statusMessage ||
            p.estimatedMinutes != c.estimatedMinutes ||
            p.distanceKm != c.distanceKm ||
            p.orderStatus != c.orderStatus,
        listener: (context, state) {
          _updateCourierMarker(state);

          // Afficher les erreurs
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Carte Google Maps — wrapped in ListenableBuilder so only
              // the map re-renders when markers/polylines change, NOT the
              // entire BlocConsumer tree (header, FABs, info card).
              ListenableBuilder(
                listenable: Listenable.merge([
                  _markersNotifier,
                  _polylinesNotifier,
                ]),
                builder: (context, _) => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.pickupLatitude != null
                        ? LatLng(
                            widget.pickupLatitude!,
                            widget.pickupLongitude!,
                          )
                        : _defaultPosition,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                    // Ajuster la vue après création
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) _fitAllMarkers();
                    });
                  },
                  markers: _markersNotifier.value,
                  polylines: _polylinesNotifier.value,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),

              // Header avec bouton retour
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Suivi en direct',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '#${widget.trackingCode}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildConnectionIndicator(state.connectionStatus),
                      ],
                    ),
                  ),
                ),
              ),

              // Boutons de la carte
              Positioned(
                right: 16,
                bottom: 240,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'fit',
                      onPressed: _fitAllMarkers,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      child: const Icon(Icons.fit_screen),
                    ),
                    const SizedBox(height: 8),
                    if (state.hasCourierLocation)
                      FloatingActionButton.small(
                        heroTag: 'courier',
                        onPressed: () => _animateCameraToPosition(
                          LatLng(
                            state.courierLatitude!,
                            state.courierLongitude!,
                          ),
                        ),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.delivery_dining),
                      ),
                  ],
                ),
              ),

              // Bottom sheet avec infos
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildInfoCard(state),
              ),

              // Bannière de déconnexion WebSocket — visible dès que la
              // connexion est perdue, pour ne pas laisser l'utilisateur
              // croire que le coursier est immobile.
              if (state.connectionStatus ==
                      TrackingConnectionStatus.reconnecting ||
                  state.connectionStatus == TrackingConnectionStatus.error ||
                  state.connectionStatus ==
                      TrackingConnectionStatus.disconnected)
                Positioned(
                  left: 0,
                  right: 0,
                  top: kToolbarHeight + MediaQuery.of(context).padding.top,
                  child: _buildDisconnectionBanner(state.connectionStatus),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Bannière pleine largeur affichée quand le WebSocket est déconnecté.
  /// Évite que l'utilisateur croie que le coursier est immobile alors
  /// que la connexion temps réel est perdue.
  Widget _buildDisconnectionBanner(TrackingConnectionStatus status) {
    final isReconnecting = status == TrackingConnectionStatus.reconnecting;
    return Material(
      color: isReconnecting ? Colors.orange.shade700 : Colors.red.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              isReconnecting ? Icons.wifi_protected_setup : Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isReconnecting
                    ? 'Reconnexion en cours… La position peut être obsolète.'
                    : 'Connexion perdue. La position du coursier n\'est plus mise à jour.',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(TrackingConnectionStatus status) {
    Color color;
    IconData icon;
    String tooltip;

    switch (status) {
      case TrackingConnectionStatus.connected:
        color = Colors.green;
        icon = Icons.wifi;
        tooltip = 'Connecté';
        break;
      case TrackingConnectionStatus.connecting:
        color = Colors.orange;
        icon = Icons.wifi_find;
        tooltip = 'Connexion...';
        break;
      case TrackingConnectionStatus.reconnecting:
        color = Colors.orange;
        icon = Icons.wifi_protected_setup;
        tooltip = 'Reconnexion...';
        break;
      case TrackingConnectionStatus.error:
        color = Colors.red;
        icon = Icons.wifi_off;
        tooltip = 'Déconnecté';
        break;
      default:
        color = Colors.grey;
        icon = Icons.wifi_off;
        tooltip = 'Non connecté';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildInfoCard(LiveTrackingState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
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
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        state.orderStatus,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(state.orderStatus),
                      color: _getStatusColor(state.orderStatus),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.statusMessage ?? 'En attente...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (state.estimatedMinutes != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Arrivée estimée: ${state.estimatedMinutes} min (${state.distanceKm?.toStringAsFixed(1)} km)',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Coursier info
            if (widget.courierName != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courierName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Votre coursier',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.courierPhone != null) ...[
                      IconButton(
                        onPressed: _callCourier,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                        ),
                        icon: const Icon(Icons.phone, color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'picking_up':
        return Colors.blue;
      case 'picked_up':
        return Colors.orange;
      case 'delivering':
        return AppColors.primary;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'picking_up':
        return Icons.directions_walk;
      case 'picked_up':
        return Icons.inventory_2;
      case 'delivering':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }
}
