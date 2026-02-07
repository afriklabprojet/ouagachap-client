import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/services/geocoding_service.dart';
import '../../../core/theme/app_colors.dart';

/// Page de sélection d'adresse sur carte
class MapPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? title;

  const MapPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.title,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final GeocodingService _geocodingService = GeocodingService();
  final TextEditingController _searchController = TextEditingController();

  // Coordonnées par défaut : centre de Ouagadougou
  static const LatLng _defaultPosition = LatLng(12.3714, -1.5197);

  late LatLng _selectedPosition;
  String _selectedAddress = 'Chargement...';
  bool _isLoading = false;
  bool _isSearching = false;
  List<GeocodingResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialLatitude != null && widget.initialLongitude != null
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : _defaultPosition;
    _getAddressFromPosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromPosition() async {
    setState(() => _isLoading = true);

    final result = await _geocodingService.getAddressFromCoordinates(
      _selectedPosition.latitude,
      _selectedPosition.longitude,
    );

    if (mounted) {
      setState(() {
        _selectedAddress = result?.shortAddress ?? 'Adresse inconnue';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = await _geocodingService.searchAddress(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permission de localisation refusée');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Activez la localisation dans les paramètres');
        return;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final newPosition = LatLng(position.latitude, position.longitude);
      
      // Déplacer la carte
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(newPosition));

      setState(() => _selectedPosition = newPosition);
      _getAddressFromPosition();
    } catch (e) {
      _showError('Impossible d\'obtenir votre position');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedPosition = position);
    _getAddressFromPosition();
  }

  void _selectSearchResult(GeocodingResult result) async {
    final newPosition = LatLng(result.latitude, result.longitude);

    // Déplacer la carte
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 17));

    setState(() {
      _selectedPosition = newPosition;
      _selectedAddress = result.shortAddress;
      _searchResults = [];
      _searchController.clear();
    });
    
    FocusScope.of(context).unfocus();
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'latitude': _selectedPosition.latitude,
      'longitude': _selectedPosition.longitude,
      'address': _selectedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Sélectionner une adresse'),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text(
              'Confirmer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
            onTap: _onMapTap,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange,
                ),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Barre de recherche
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une adresse...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _searchAddress,
                  ),
                ),
                // Résultats de recherche
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            result.shortAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            result.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
                if (_isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bouton ma position
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              heroTag: 'location',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Carte d'adresse sélectionnée
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Adresse sélectionnée',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 100,
                                    child: LinearProgressIndicator(),
                                  )
                                : Text(
                                    _selectedAddress,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmSelection,
                      icon: const Icon(Icons.check),
                      label: const Text('Utiliser cette adresse'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
}
