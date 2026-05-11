import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../address/domain/entities/saved_address.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/bloc/address_event.dart';
import '../../../address/presentation/bloc/address_state.dart';
import '../../../address/presentation/pages/map_picker_page.dart';

/// Données de l'étape pickup transmises au parent.
class PickupData {
  final String address;
  final double latitude;
  final double longitude;
  final bool coordsSet;
  final String? contactName;
  final String? contactPhone;

  const PickupData({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.coordsSet,
    this.contactName,
    this.contactPhone,
  });
}

/// Étape 1 — Formulaire de récupération.
class StepPickupWidget extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final double latitude;
  final double longitude;
  final bool coordsSet;
  final bool isGpsLoading;
  final ValueChanged<PickupData> onCoordsUpdated;
  final ValueChanged<bool> onGpsLoadingChanged;

  const StepPickupWidget({
    super.key,
    required this.addressController,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.latitude,
    required this.longitude,
    required this.coordsSet,
    required this.isGpsLoading,
    required this.onCoordsUpdated,
    required this.onGpsLoadingChanged,
  });

  @override
  State<StepPickupWidget> createState() => _StepPickupWidgetState();
}

class _StepPickupWidgetState extends State<StepPickupWidget> {
  final GeocodingService _geocodingService = getIt<GeocodingService>();
  Timer? _searchDebounce;
  List<GeocodingResult> _searchResults = [];
  bool _isSearching = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-déclenche le GPS au chargement si le champ adresse est vide
    if (widget.addressController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.addressController.text.isEmpty) {
          _useCurrentLocation();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAddressChanged(String value) {
    _searchDebounce?.cancel();
    if (value.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      // Reset coords when user types manually
      widget.onCoordsUpdated(
        PickupData(
          address: value,
          latitude: widget.latitude,
          longitude: widget.longitude,
          coordsSet: false,
          contactName: widget.contactNameController.text,
          contactPhone: widget.contactPhoneController.text,
        ),
      );
      return;
    }
    setState(() => _isSearching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 600), () async {
      final results = await _geocodingService.searchAddress(value);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  void _selectSearchResult(GeocodingResult result) {
    widget.addressController.text = result.shortAddress;
    setState(() {
      _searchResults = [];
    });
    _focusNode.unfocus();
    widget.onCoordsUpdated(
      PickupData(
        address: result.shortAddress,
        latitude: result.latitude,
        longitude: result.longitude,
        coordsSet: true,
        contactName: widget.contactNameController.text,
        contactPhone: widget.contactPhoneController.text,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Position GPS définie : ${result.shortAddress}'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    widget.onGpsLoadingChanged(true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          _showError('Permission de localisation refusée');
          widget.onGpsLoadingChanged(false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        widget.onGpsLoadingChanged(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Activez la localisation dans les paramètres'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'OUVRIR',
              textColor: Colors.white,
              onPressed: () => Geolocator.openAppSettings(),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      final result = await _geocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      final address = result?.shortAddress ?? 'Position actuelle';
      widget.addressController.text = address;
      setState(() => _searchResults = []);
      widget.onCoordsUpdated(
        PickupData(
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
          coordsSet: true,
          contactName: widget.contactNameController.text,
          contactPhone: widget.contactPhoneController.text,
        ),
      );
      widget.onGpsLoadingChanged(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.my_location, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Position GPS détectée !')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      widget.onGpsLoadingChanged(false);
      _showError('Impossible d\'obtenir la position GPS.');
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLatitude: widget.latitude,
          initialLongitude: widget.longitude,
          title: 'Adresse de récupération',
        ),
      ),
    );
    if (result != null && mounted) {
      widget.addressController.text = result['address'];
      widget.onCoordsUpdated(
        PickupData(
          address: result['address'],
          latitude: result['latitude'],
          longitude: result['longitude'],
          coordsSet: true,
          contactName: widget.contactNameController.text,
          contactPhone: widget.contactPhoneController.text,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adresse de récupération sélectionnée'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) => getIt<AddressBloc>()..add(const LoadAddresses()),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sélectionner adresse de récupération',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: BlocBuilder<AddressBloc, AddressState>(
                    buildWhen: (p, c) =>
                        p.status != c.status || p.addresses != c.addresses,
                    builder: (ctx, state) {
                      if (state.status == AddressStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.addresses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune adresse sauvegardée',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.go(
                                    '${Routes.profile}/${Routes.addresses}',
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter une adresse'),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.addresses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final address = state.addresses[index];
                          return _buildAddressCard(address);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(SavedAddress address) {
    IconData typeIcon;
    switch (address.type) {
      case AddressType.home:
        typeIcon = Icons.home_outlined;
      case AddressType.work:
        typeIcon = Icons.work_outline;
      case AddressType.other:
        typeIcon = Icons.location_on_outlined;
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          widget.addressController.text = address.address;
          widget.onCoordsUpdated(
            PickupData(
              address: address.address,
              latitude: address.latitude,
              longitude: address.longitude,
              coordsSet: true,
              contactName: widget.contactNameController.text,
              contactPhone: widget.contactPhoneController.text,
            ),
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Adresse "${address.label}" sélectionnée'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(typeIcon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Par défaut',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.address,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ListTile(
            dense: true,
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            title: Text(
              result.shortAddress,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.displayName,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSearchResult(result),
          );
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeInWidget(
            delay: Duration(milliseconds: 100),
            child: Text(
              'Adresse de récupération',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FadeInWidget(
            delay: const Duration(milliseconds: 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Où devons-nous récupérer votre colis ?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton.icon(
                  onPressed: _showAddressSelector,
                  icon: const Icon(Icons.bookmark_outline, size: 18),
                  label: const Text('Mes adresses'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SlideInWidget(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                TextFormField(
                  controller: widget.addressController,
                  focusNode: _focusNode,
                  onChanged: _onAddressChanged,
                  decoration: InputDecoration(
                    labelText: 'Adresse de récupération *',
                    hintText: 'Tapez ex: Ouaga 2000, Patte d\'oie...',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.map_outlined,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Choisir sur la carte',
                            onPressed: _openMapPicker,
                          ),
                  ),
                  maxLines: 2,
                ),
                if (_searchResults.isNotEmpty) _buildSearchResults(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SlideInWidget(
            delay: const Duration(milliseconds: 220),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.isGpsLoading ? null : _useCurrentLocation,
                    icon: widget.isGpsLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 20),
                    label: const Text('Ma position'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMapPicker,
                    icon: const Icon(Icons.map, size: 20),
                    label: const Text('Sur la carte'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.coordsSet)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Position GPS confirmée',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          FadeInWidget(
            delay: const Duration(milliseconds: 250),
            child: Text(
              'Contact sur place (optionnel)',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SlideInWidget(
            delay: const Duration(milliseconds: 300),
            child: TextFormField(
              controller: widget.contactNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du contact',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SlideInWidget(
            delay: const Duration(milliseconds: 350),
            child: TextFormField(
              controller: widget.contactPhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(
                labelText: 'Téléphone du contact',
                hintText: '70 00 00 00',
                prefixIcon: Container(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('+226', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
