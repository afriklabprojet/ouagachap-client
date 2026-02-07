import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/lottie_animations.dart';
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

  // Mock coordinates (Ouagadougou)
  double _pickupLatitude = 12.3714;
  double _pickupLongitude = -1.5197;
  double _deliveryLatitude = 12.3814;
  double _deliveryLongitude = -1.5097;

  double _estimatedPrice = 0;
  double _estimatedDistance = 0;

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
        return true;
      case 1:
        if (_deliveryAddressController.text.isEmpty) {
          _showError('Veuillez entrer l\'adresse de livraison');
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
        return true;
      default:
        return true;
    }
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
    final phone = '+226${_recipientPhoneController.text.replaceAll(' ', '')}';
    
    context.read<OrderBloc>().add(CreateOrderRequested(
          pickupAddress: _pickupAddressController.text,
          pickupLatitude: _pickupLatitude,
          pickupLongitude: _pickupLongitude,
          pickupContactName: _pickupContactNameController.text.isEmpty
              ? null
              : _pickupContactNameController.text,
          pickupContactPhone: _pickupContactPhoneController.text.isEmpty
              ? null
              : '+226${_pickupContactPhoneController.text.replaceAll(' ', '')}',
          deliveryAddress: _deliveryAddressController.text,
          deliveryLatitude: _deliveryLatitude,
          deliveryLongitude: _deliveryLongitude,
          recipientName: _recipientNameController.text,
          recipientPhone: phone,
          packageDescription: _packageDescriptionController.text.isEmpty
              ? null
              : _packageDescriptionController.text,
          packageSize: _selectedPackageSize,
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
          });
        } else if (state is OrderCreated) {
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
            child: Text(
              'Où devons-nous récupérer votre colis ?',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          SlideInWidget(
            delay: const Duration(milliseconds: 200),
            child: TextFormField(
              controller: _pickupAddressController,
              decoration: const InputDecoration(
                labelText: 'Adresse de récupération *',
                hintText: 'Ex: Quartier Patte d\'oie, Secteur 15',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              maxLines: 2,
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
          Text(
            'Où devons-nous livrer votre colis ?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _deliveryAddressController,
            decoration: const InputDecoration(
              labelText: 'Adresse de livraison *',
              hintText: 'Ex: Avenue Kwame Nkrumah, Ouaga 2000',
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 2,
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
}
