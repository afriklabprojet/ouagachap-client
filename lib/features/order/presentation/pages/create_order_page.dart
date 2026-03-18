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
import '../../../../core/widgets/lottie_animations.dart';
import '../../../address/domain/entities/saved_address.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/bloc/address_event.dart';
import '../../../address/presentation/bloc/address_state.dart';
import '../../../address/presentation/pages/map_picker_page.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Pickup
  final _pickupAddressController = TextEditingController();
  final _pickupContactNameController = TextEditingController();
  final _pickupContactPhoneController = TextEditingController();

  // Delivery
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();

  // Package
  final _packageDescriptionController = TextEditingController();
  String _selectedPackageSize = 'small';
  String _selectedPaymentMethod = 'cash';

  // Coordonnées par défaut (centre Ouagadougou) — DOIVENT être
  // remplacées via le map picker pour que la commande soit valide.
  double _pickupLatitude = 12.3714;
  double _pickupLongitude = -1.5197;
  double _deliveryLatitude = 12.3814;
  double _deliveryLongitude = -1.5097;
  bool _pickupCoordsSet = false;
  bool _deliveryCoordsSet = false;

  double _estimatedPrice = 0;
  double _estimatedDistance = 0;
  double _basePrice = 0;
  double _distancePrice = 0;
  bool _orderCreated = false;

  // Autocomplete address search
  final GeocodingService _geocodingService = GeocodingService();
  Timer? _pickupSearchDebounce;
  Timer? _deliverySearchDebounce;
  List<GeocodingResult> _pickupSearchResults = [];
  List<GeocodingResult> _deliverySearchResults = [];
  bool _isSearchingPickup = false;
  bool _isSearchingDelivery = false;
  bool _isGpsLoading = false;
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _deliveryFocusNode = FocusNode();

  @override
  void dispose() {
    _pageController.dispose();
    _pickupAddressController.dispose();
    _pickupContactNameController.dispose();
    _pickupContactPhoneController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _packageDescriptionController.dispose();
    _pickupSearchDebounce?.cancel();
    _deliverySearchDebounce?.cancel();
    _pickupFocusNode.dispose();
    _deliveryFocusNode.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        if (_currentStep == 2) {
          _calculatePrice();
        }
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_pickupAddressController.text.isEmpty) {
          _showError('Veuillez entrer l\'adresse de récupération');
          return false;
        }
        if (!_pickupCoordsSet) {
          // Auto-géocode le texte si l'utilisateur n'a pas sélectionné sur la carte
          _autoGeocodeAndProceed(isPickup: true);
          return false;
        }
        return true;
      case 1:
        if (_deliveryAddressController.text.isEmpty) {
          _showError('Veuillez entrer l\'adresse de livraison');
          return false;
        }
        if (!_deliveryCoordsSet) {
          _autoGeocodeAndProceed(isPickup: false);
          return false;
        }
        if (_recipientNameController.text.isEmpty) {
          _showError('Veuillez entrer le nom du destinataire');
          return false;
        }
        if (_recipientPhoneController.text.isEmpty) {
          _showError('Veuillez entrer le téléphone du destinataire');
          return false;
        }
        final digits = _recipientPhoneController.text.replaceAll(' ', '');
        if (digits.length != 8) {
          _showError('Le numéro du destinataire doit contenir 8 chiffres');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  /// Auto-géocode le texte saisi et avance automatiquement si trouvé
  Future<void> _autoGeocodeAndProceed({required bool isPickup}) async {
    final address = isPickup
        ? _pickupAddressController.text
        : _deliveryAddressController.text;

    _showInfo('Recherche de la position GPS pour "$address"...');

    final results = await _geocodingService.searchAddress(address);
    if (!mounted) return;

    if (results.isNotEmpty) {
      final result = results.first;
      setState(() {
        if (isPickup) {
          _pickupLatitude = result.latitude;
          _pickupLongitude = result.longitude;
          _pickupAddressController.text = result.shortAddress;
          _pickupCoordsSet = true;
        } else {
          _deliveryLatitude = result.latitude;
          _deliveryLongitude = result.longitude;
          _deliveryAddressController.text = result.shortAddress;
          _deliveryCoordsSet = true;
        }
      });
      // Réessayer la validation maintenant que les coords sont set
      _nextStep();
    } else {
      _showError('Adresse introuvable. Veuillez sélectionner sur la carte.');
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _calculatePrice() {
    context.read<OrderBloc>().add(CalculatePriceRequested(
          pickupLatitude: _pickupLatitude,
          pickupLongitude: _pickupLongitude,
          deliveryLatitude: _deliveryLatitude,
          deliveryLongitude: _deliveryLongitude,
        ));
  }

  void _submitOrder() {
    if (_orderCreated) return; // Empêcher la re-soumission
    
    final rawPhone = _recipientPhoneController.text.replaceAll(' ', '');
    final phone = rawPhone.startsWith('+226') ? rawPhone : '+226$rawPhone';
    
    context.read<OrderBloc>().add(CreateOrderRequested(
          pickupAddress: _pickupAddressController.text,
          pickupLatitude: _pickupLatitude,
          pickupLongitude: _pickupLongitude,
          pickupContactName: _pickupContactNameController.text.isEmpty
              ? null
              : _pickupContactNameController.text,
          pickupContactPhone: _pickupContactPhoneController.text.isEmpty
              ? null
              : () {
                  final raw = _pickupContactPhoneController.text.replaceAll(' ', '');
                  return raw.startsWith('+226') ? raw : '+226$raw';
                }(),
          deliveryAddress: _deliveryAddressController.text,
          deliveryLatitude: _deliveryLatitude,
          deliveryLongitude: _deliveryLongitude,
          recipientName: _recipientNameController.text,
          recipientPhone: phone,
          packageDescription: _packageDescriptionController.text.isEmpty
              ? null
              : _packageDescriptionController.text,
          packageSize: _selectedPackageSize,
          paymentMethod: _selectedPaymentMethod,
        ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is PriceCalculated) {
          setState(() {
            _estimatedPrice = state.price;
            _estimatedDistance = state.distance;
            _basePrice = state.basePrice;
            _distancePrice = state.distancePrice;
          });
        } else if (state is OrderCreated) {
          _orderCreated = true;
          // Afficher l'animation de succès
          AnimatedSuccessDialog.show(
            context,
            title: 'Commande créée !',
            message: 'Votre commande a été créée avec succès.\nRecherche d\'un coursier en cours...',
            buttonText: 'Suivre ma commande',
            onPressed: () {
              context.go('${Routes.orderTracking}/${state.order.id}');
            },
          );
        } else if (state is OrderError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle livraison'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go(Routes.home),
          ),
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            // Form pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPickupStep(),
                  _buildDeliveryStep(),
                  _buildConfirmStep(),
                ],
              ),
            ),
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Récupération'),
          _buildStepLine(0),
          _buildStepIndicator(1, 'Livraison'),
          _buildStepLine(1),
          _buildStepIndicator(2, 'Confirmation'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive && _currentStep > step
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    return Container(
      width: 40,
      height: 2,
      color: _currentStep > afterStep ? AppColors.primary : Colors.grey[300],
    );
  }

  Widget _buildPickupStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: const Text(
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
                  onPressed: () => _showAddressSelector(isPickup: true),
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
          // Address field with autocomplete
          SlideInWidget(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                TextFormField(
                  controller: _pickupAddressController,
                  focusNode: _pickupFocusNode,
                  onChanged: (value) => _onAddressChanged(value, isPickup: true),
                  decoration: InputDecoration(
                    labelText: 'Adresse de récupération *',
                    hintText: 'Tapez ex: Ouaga 2000, Patte d\'oie...',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _isSearchingPickup
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                            tooltip: 'Choisir sur la carte',
                            onPressed: () => _openMapPicker(isPickup: true),
                          ),
                  ),
                  maxLines: 2,
                ),
                // Autocomplete results dropdown
                if (_pickupSearchResults.isNotEmpty)
                  _buildSearchResults(_pickupSearchResults, isPickup: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // GPS + Map buttons row
          SlideInWidget(
            delay: const Duration(milliseconds: 220),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGpsLoading ? null : () => _useCurrentLocation(isPickup: true),
                    icon: _isGpsLoading
                        ? const SizedBox(
                            width: 18, height: 18,
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
                    onPressed: () => _openMapPicker(isPickup: true),
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
          // Show GPS confirmation chip
          if (_pickupCoordsSet)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Position GPS confirmée',
                      style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
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
              controller: _pickupContactNameController,
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
              controller: _pickupContactPhoneController,
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

  Widget _buildDeliveryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adresse de livraison',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Où devons-nous livrer votre colis ?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton.icon(
                onPressed: () => _showAddressSelector(isPickup: false),
                icon: const Icon(Icons.bookmark_outline, size: 18),
                label: const Text('Mes adresses'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Address field with autocomplete
          Column(
            children: [
              TextFormField(
                controller: _deliveryAddressController,
                focusNode: _deliveryFocusNode,
                onChanged: (value) => _onAddressChanged(value, isPickup: false),
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison *',
                  hintText: 'Tapez ex: Ouaga 2000, Karpala...',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _isSearchingDelivery
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                          tooltip: 'Choisir sur la carte',
                          onPressed: () => _openMapPicker(isPickup: false),
                        ),
                ),
                maxLines: 2,
              ),
              // Autocomplete results dropdown
              if (_deliverySearchResults.isNotEmpty)
                _buildSearchResults(_deliverySearchResults, isPickup: false),
            ],
          ),
          const SizedBox(height: 12),
          // GPS + Map buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGpsLoading ? null : () => _useCurrentLocation(isPickup: false),
                  icon: _isGpsLoading
                      ? const SizedBox(
                          width: 18, height: 18,
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
                  onPressed: () => _openMapPicker(isPickup: false),
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text('Sur la carte'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ],
          ),
          // Show GPS confirmation chip
          if (_deliveryCoordsSet)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Position GPS confirmée',
                      style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Informations du destinataire',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _recipientNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du destinataire *',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _recipientPhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: InputDecoration(
              labelText: 'Téléphone du destinataire *',
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
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Description du colis (optionnel)',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _packageDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Ex: Documents, Petit carton...',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            maxLines: 2,
            maxLength: 200,
          ),
          const SizedBox(height: 16),
          const Text('Taille du colis'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSizeOption('small', 'Petit', Icons.mail_outline),
              const SizedBox(width: 8),
              _buildSizeOption('medium', 'Moyen', Icons.inventory_2_outlined),
              const SizedBox(width: 8),
              _buildSizeOption('large', 'Grand', Icons.local_shipping_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String value, String label, IconData icon) {
    final isSelected = _selectedPackageSize == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPackageSize = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInWidget(
            delay: const Duration(milliseconds: 100),
            child: const Text(
              'Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FadeInWidget(
            delay: const Duration(milliseconds: 150),
            child: Text(
              'Vérifiez les informations de votre commande',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          // Pickup summary
          SlideInWidget(
            delay: const Duration(milliseconds: 200),
            child: _buildSummaryCard(
              title: 'Récupération',
              icon: Icons.location_on_outlined,
              iconColor: AppColors.primary,
              items: [
                _pickupAddressController.text,
              if (_pickupContactNameController.text.isNotEmpty)
                'Contact: ${_pickupContactNameController.text}',
              if (_pickupContactPhoneController.text.isNotEmpty)
                'Tél: +226 ${_pickupContactPhoneController.text}',
            ],
            ),
          ),
          const SizedBox(height: 16),
          // Delivery summary
          SlideInWidget(
            delay: const Duration(milliseconds: 300),
            child: _buildSummaryCard(
              title: 'Livraison',
              icon: Icons.location_on,
              iconColor: AppColors.secondary,
              items: [
                _deliveryAddressController.text,
                'Destinataire: ${_recipientNameController.text}',
                'Tél: +226 ${_recipientPhoneController.text}',
                if (_packageDescriptionController.text.isNotEmpty)
                  'Colis: ${_packageDescriptionController.text}',
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Price summary
          ScaleInWidget(
            delay: const Duration(milliseconds: 400),
            child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Distance estimée'),
                    Text('${_estimatedDistance.toStringAsFixed(1)} km'),
                  ],
                ),
                if (_basePrice > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Prix de base'),
                      Text('${_basePrice.toInt()} FCFA'),
                    ],
                  ),
                ],
                if (_distancePrice > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Prix distance'),
                      Text('${_distancePrice.toInt()} FCFA'),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prix total',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${_estimatedPrice.toInt()} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 24),
          // Payment method selection
          SlideInWidget(
            delay: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode de paiement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  id: 'cash',
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                  title: 'Espèces',
                  subtitle: 'Payer à la livraison',
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  id: 'orange_money',
                  icon: Icons.phone_android,
                  color: Colors.orange,
                  title: 'Orange Money',
                  subtitle: 'Payer par mobile money',
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  id: 'moov_money',
                  icon: Icons.phone_android,
                  color: Colors.blue,
                  title: 'Moov Money',
                  subtitle: 'Payer par mobile money',
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  id: 'wave',
                  icon: Icons.waves,
                  color: Colors.lightBlue,
                  title: 'Wave',
                  subtitle: 'Payer par Wave',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.black87)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withOpacity(0.7)
                              : Colors.grey[600])),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final isLoading = state is OrderLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : _currentStep == 2
                          ? _submitOrder
                          : _nextStep,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_currentStep == 2 ? 'Confirmer' : 'Suivant'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelector({required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => getIt<AddressBloc>()..add(LoadAddresses()),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPickup
                            ? 'Sélectionner adresse de récupération'
                            : 'Sélectionner adresse de livraison',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Address list
                Expanded(
                  child: BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, state) {
                      if (state.status == AddressStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
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
                                  Navigator.pop(context);
                                  context.go(
                                      '${Routes.profile}/${Routes.addresses}');
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
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final address = state.addresses[index];
                          return _buildAddressCard(address, isPickup);
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

  Widget _buildAddressCard(SavedAddress address, bool isPickup) {
    IconData typeIcon;
    switch (address.type) {
      case AddressType.home:
        typeIcon = Icons.home_outlined;
        break;
      case AddressType.work:
        typeIcon = Icons.work_outline;
        break;
      case AddressType.other:
        typeIcon = Icons.location_on_outlined;
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isPickup) {
              _pickupAddressController.text = address.address;
              _pickupLatitude = address.latitude;
              _pickupLongitude = address.longitude;
              _pickupCoordsSet = true;
            } else {
              _deliveryAddressController.text = address.address;
              _deliveryLatitude = address.latitude;
              _deliveryLongitude = address.longitude;
              _deliveryCoordsSet = true;
            }
          });
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
                              color: AppColors.primary.withOpacity(0.1),
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
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

  // ─── Autocomplete address search ───────────────────────────────

  void _onAddressChanged(String value, {required bool isPickup}) {
    // Reset coords when user types manually
    if (isPickup) {
      _pickupCoordsSet = false;
    } else {
      _deliveryCoordsSet = false;
    }

    // Cancel previous debounce
    if (isPickup) {
      _pickupSearchDebounce?.cancel();
    } else {
      _deliverySearchDebounce?.cancel();
    }

    if (value.length < 3) {
      setState(() {
        if (isPickup) {
          _pickupSearchResults = [];
          _isSearchingPickup = false;
        } else {
          _deliverySearchResults = [];
          _isSearchingDelivery = false;
        }
      });
      return;
    }

    setState(() {
      if (isPickup) {
        _isSearchingPickup = true;
      } else {
        _isSearchingDelivery = true;
      }
    });

    final timer = Timer(const Duration(milliseconds: 600), () async {
      final results = await _geocodingService.searchAddress(value);
      if (!mounted) return;
      setState(() {
        if (isPickup) {
          _pickupSearchResults = results;
          _isSearchingPickup = false;
        } else {
          _deliverySearchResults = results;
          _isSearchingDelivery = false;
        }
      });
    });

    if (isPickup) {
      _pickupSearchDebounce = timer;
    } else {
      _deliverySearchDebounce = timer;
    }
  }

  void _selectSearchResult(GeocodingResult result, {required bool isPickup}) {
    setState(() {
      if (isPickup) {
        _pickupAddressController.text = result.shortAddress;
        _pickupLatitude = result.latitude;
        _pickupLongitude = result.longitude;
        _pickupCoordsSet = true;
        _pickupSearchResults = [];
        _pickupFocusNode.unfocus();
      } else {
        _deliveryAddressController.text = result.shortAddress;
        _deliveryLatitude = result.latitude;
        _deliveryLongitude = result.longitude;
        _deliveryCoordsSet = true;
        _deliverySearchResults = [];
        _deliveryFocusNode.unfocus();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Position GPS définie : ${result.shortAddress}')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSearchResults(List<GeocodingResult> results, {required bool isPickup}) {
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
        itemCount: results.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final result = results[index];
          return ListTile(
            dense: true,
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: AppColors.primary, size: 18),
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
            onTap: () => _selectSearchResult(result, isPickup: isPickup),
          );
        },
      ),
    );
  }

  // ─── GPS current location ─────────────────────────────────────

  Future<void> _useCurrentLocation({required bool isPickup}) async {
    setState(() => _isGpsLoading = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          _showError('Permission de localisation refusée');
          setState(() => _isGpsLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isGpsLoading = false);
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

      // Reverse geocode to get address text
      final result = await _geocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      setState(() {
        if (isPickup) {
          _pickupLatitude = position.latitude;
          _pickupLongitude = position.longitude;
          _pickupAddressController.text = result?.shortAddress ?? 'Position actuelle';
          _pickupCoordsSet = true;
          _pickupSearchResults = [];
        } else {
          _deliveryLatitude = position.latitude;
          _deliveryLongitude = position.longitude;
          _deliveryAddressController.text = result?.shortAddress ?? 'Position actuelle';
          _deliveryCoordsSet = true;
          _deliverySearchResults = [];
        }
        _isGpsLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.my_location, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text('Position GPS détectée !')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGpsLoading = false);
      _showError('Impossible d\'obtenir la position GPS. Vérifiez que la localisation est activée.');
    }
  }

  Future<void> _openMapPicker({required bool isPickup}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLatitude: isPickup ? _pickupLatitude : _deliveryLatitude,
          initialLongitude: isPickup ? _pickupLongitude : _deliveryLongitude,
          title: isPickup
              ? 'Adresse de récupération'
              : 'Adresse de livraison',
        ),
      ),
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        if (isPickup) {
          _pickupLatitude = result['latitude'];
          _pickupLongitude = result['longitude'];
          _pickupAddressController.text = result['address'];
          _pickupCoordsSet = true;
        } else {
          _deliveryLatitude = result['latitude'];
          _deliveryLongitude = result['longitude'];
          _deliveryAddressController.text = result['address'];
          _deliveryCoordsSet = true;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'Adresse de récupération sélectionnée'
                : 'Adresse de livraison sélectionnée',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
