import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/services/order_draft_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../bloc/create_order_form_cubit.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_step_indicator.dart';
import '../widgets/step_confirm_widget.dart';
import '../widgets/step_delivery_widget.dart';
import '../widgets/step_pickup_widget.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _pageController = PageController();

  // TextEditingControllers restent dans la page (liés aux champs UI)
  final _pickupAddressController = TextEditingController();
  final _pickupContactNameController = TextEditingController();
  final _pickupContactPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _packageDescriptionController = TextEditingController();

  late final CreateOrderFormCubit _formCubit;
  late final OrderDraftService _draftService;

  @override
  void initState() {
    super.initState();
    _draftService = getIt<OrderDraftService>();
    _formCubit = CreateOrderFormCubit(
      geocodingService: getIt<GeocodingService>(),
    );
    // Restaurer le brouillon si disponible
    final draft = _draftService.loadDraft();
    if (draft != null) {
      _pickupAddressController.text = draft['pickupAddress'] as String? ?? '';
      _pickupContactNameController.text =
          draft['pickupContactName'] as String? ?? '';
      _pickupContactPhoneController.text =
          draft['pickupContactPhone'] as String? ?? '';
      _deliveryAddressController.text =
          draft['deliveryAddress'] as String? ?? '';
      _recipientNameController.text = draft['recipientName'] as String? ?? '';
      _recipientPhoneController.text = draft['recipientPhone'] as String? ?? '';
      _packageDescriptionController.text =
          draft['packageDescription'] as String? ?? '';
      if (draft['pickupLatitude'] != null && draft['pickupLongitude'] != null) {
        _formCubit.updatePickupCoords(
          CoordsData(
            latitude: (draft['pickupLatitude'] as num).toDouble(),
            longitude: (draft['pickupLongitude'] as num).toDouble(),
            coordsSet: true,
          ),
        );
      }
      if (draft['deliveryLatitude'] != null &&
          draft['deliveryLongitude'] != null) {
        _formCubit.updateDeliveryCoords(
          CoordsData(
            latitude: (draft['deliveryLatitude'] as num).toDouble(),
            longitude: (draft['deliveryLongitude'] as num).toDouble(),
            coordsSet: true,
          ),
        );
      }
      if (draft['packageSize'] != null) {
        _formCubit.setPackageSize(draft['packageSize'] as String);
      }
      if (draft['paymentMethod'] != null) {
        _formCubit.setPaymentMethod(draft['paymentMethod'] as String);
      }
    }
  }

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
    _formCubit.close();
    super.dispose();
  }

  void _nextStep() {
    final advanced = _formCubit.validateAndAdvance(
      pickupAddress: _pickupAddressController.text,
      deliveryAddress: _deliveryAddressController.text,
      recipientName: _recipientNameController.text,
      recipientPhone: _recipientPhoneController.text,
    );
    if (advanced) {
      // Persister le brouillon à chaque étape validée
      final s = _formCubit.state;
      _draftService.saveDraft(
        pickupAddress: _pickupAddressController.text,
        pickupLatitude: s.pickupLatitude,
        pickupLongitude: s.pickupLongitude,
        pickupContactName: _pickupContactNameController.text.isEmpty
            ? null
            : _pickupContactNameController.text,
        pickupContactPhone: _pickupContactPhoneController.text.isEmpty
            ? null
            : _pickupContactPhoneController.text,
        deliveryAddress: _deliveryAddressController.text,
        deliveryLatitude: s.deliveryLatitude,
        deliveryLongitude: s.deliveryLongitude,
        recipientName: _recipientNameController.text,
        recipientPhone: _recipientPhoneController.text,
        packageDescription: _packageDescriptionController.text.isEmpty
            ? null
            : _packageDescriptionController.text,
        packageSize: s.selectedPackageSize,
        paymentMethod: s.selectedPaymentMethod,
        currentStep: s.currentStep,
      );
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      if (_formCubit.state.currentStep == 2) {
        _calculatePrice();
      }
    }
  }

  void _previousStep() {
    _formCubit.goBack();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _calculatePrice() {
    final s = _formCubit.state;
    context.read<OrderBloc>().add(
      CalculatePriceRequested(
        pickupLatitude: s.pickupLatitude,
        pickupLongitude: s.pickupLongitude,
        deliveryLatitude: s.deliveryLatitude,
        deliveryLongitude: s.deliveryLongitude,
      ),
    );
  }

  void _submitOrder() {
    final s = _formCubit.state;
    if (s.orderCreated) return;

    final rawPhone = _recipientPhoneController.text.replaceAll(' ', '');
    final phone = rawPhone.startsWith('+226') ? rawPhone : '+226$rawPhone';

    context.read<OrderBloc>().add(
      CreateOrderRequested(
        pickupAddress: _pickupAddressController.text,
        pickupLatitude: s.pickupLatitude,
        pickupLongitude: s.pickupLongitude,
        pickupContactName: _pickupContactNameController.text.isEmpty
            ? null
            : _pickupContactNameController.text,
        pickupContactPhone: _pickupContactPhoneController.text.isEmpty
            ? null
            : () {
                final raw = _pickupContactPhoneController.text.replaceAll(
                  ' ',
                  '',
                );
                return raw.startsWith('+226') ? raw : '+226$raw';
              }(),
        deliveryAddress: _deliveryAddressController.text,
        deliveryLatitude: s.deliveryLatitude,
        deliveryLongitude: s.deliveryLongitude,
        recipientName: _recipientNameController.text,
        recipientPhone: phone,
        packageDescription: _packageDescriptionController.text.isEmpty
            ? null
            : _packageDescriptionController.text,
        packageSize: s.selectedPackageSize,
        paymentMethod: s.selectedPaymentMethod,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // OrderBloc → forward price/creation results au form cubit
        BlocListener<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is PriceCalculated) {
              _formCubit.updatePrice(
                price: state.price,
                distance: state.distance,
                basePrice: state.basePrice,
                distancePrice: state.distancePrice,
                isSurge: state.isSurge,
                surgeMultiplier: state.surgeMultiplier,
              );
            } else if (state is OrderCreated) {
              _formCubit.markOrderCreated();
              _draftService.clearDraft(); // Brouillon effacé après succès
              AnimatedSuccessDialog.show(
                context,
                title: context.l10n.orderConfirmed,
                message:
                    'Votre commande a été créée avec succès.\nRecherche d\'un coursier en cours...',
                buttonText: context.l10n.trackOrder,
                onPressed: () {
                  context.go('${Routes.orderTracking}/${state.order.id}');
                },
              );
            } else if (state is OrderError) {
              _showError(state.message);
            }
          },
        ),
        // Form Cubit → messages (erreurs/infos)
        BlocListener<CreateOrderFormCubit, CreateOrderFormState>(
          bloc: _formCubit,
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage ||
              prev.infoMessage != curr.infoMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              _showError(state.errorMessage!);
              _formCubit.clearMessages();
            }
            if (state.infoMessage != null) {
              _showInfo(state.infoMessage!);
              _formCubit.clearMessages();
            }
          },
        ),
      ],
      child: BlocBuilder<CreateOrderFormCubit, CreateOrderFormState>(
        bloc: _formCubit,
        buildWhen: (p, c) =>
            p.currentStep != c.currentStep ||
            p.isGpsLoading != c.isGpsLoading ||
            p.pickupCoordsSet != c.pickupCoordsSet ||
            p.deliveryCoordsSet != c.deliveryCoordsSet ||
            p.pickupLatitude != c.pickupLatitude ||
            p.pickupLongitude != c.pickupLongitude ||
            p.deliveryLatitude != c.deliveryLatitude ||
            p.deliveryLongitude != c.deliveryLongitude ||
            p.selectedPackageSize != c.selectedPackageSize ||
            p.selectedPaymentMethod != c.selectedPaymentMethod ||
            p.estimatedPrice != c.estimatedPrice ||
            p.estimatedDistance != c.estimatedDistance ||
            p.basePrice != c.basePrice ||
            p.distancePrice != c.distancePrice ||
            p.orderCreated != c.orderCreated,
        builder: (context, formState) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) context.go(Routes.home);
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
                  OrderStepIndicator(currentStep: formState.currentStep),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StepPickupWidget(
                          addressController: _pickupAddressController,
                          contactNameController: _pickupContactNameController,
                          contactPhoneController: _pickupContactPhoneController,
                          latitude: formState.pickupLatitude,
                          longitude: formState.pickupLongitude,
                          coordsSet: formState.pickupCoordsSet,
                          isGpsLoading: formState.isGpsLoading,
                          onCoordsUpdated: (data) =>
                              _formCubit.updatePickupCoords(
                                CoordsData(
                                  latitude: data.latitude,
                                  longitude: data.longitude,
                                  coordsSet: data.coordsSet,
                                ),
                              ),
                          onGpsLoadingChanged: _formCubit.setGpsLoading,
                        ),
                        StepDeliveryWidget(
                          addressController: _deliveryAddressController,
                          recipientNameController: _recipientNameController,
                          recipientPhoneController: _recipientPhoneController,
                          packageDescriptionController:
                              _packageDescriptionController,
                          latitude: formState.deliveryLatitude,
                          longitude: formState.deliveryLongitude,
                          coordsSet: formState.deliveryCoordsSet,
                          isGpsLoading: formState.isGpsLoading,
                          selectedPackageSize: formState.selectedPackageSize,
                          onCoordsUpdated: (data) =>
                              _formCubit.updateDeliveryCoords(
                                CoordsData(
                                  latitude: data.latitude,
                                  longitude: data.longitude,
                                  coordsSet: data.coordsSet,
                                ),
                              ),
                          onGpsLoadingChanged: _formCubit.setGpsLoading,
                          onPackageSizeChanged: _formCubit.setPackageSize,
                        ),
                        StepConfirmWidget(
                          pickupAddress: _pickupAddressController.text,
                          pickupContactName: _pickupContactNameController.text,
                          pickupContactPhone:
                              _pickupContactPhoneController.text,
                          deliveryAddress: _deliveryAddressController.text,
                          recipientName: _recipientNameController.text,
                          recipientPhone: _recipientPhoneController.text,
                          packageDescription:
                              _packageDescriptionController.text,
                          estimatedDistance: formState.estimatedDistance,
                          basePrice: formState.basePrice,
                          distancePrice: formState.distancePrice,
                          estimatedPrice: formState.estimatedPrice,
                          isSurge: formState.isSurge,
                          surgeMultiplier: formState.surgeMultiplier,
                          selectedPaymentMethod:
                              formState.selectedPaymentMethod,
                          onPaymentMethodChanged: _formCubit.setPaymentMethod,
                        ),
                      ],
                    ),
                  ),
                  _buildNavigationButtons(formState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons(CreateOrderFormState formState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (formState.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Précédent'),
              ),
            ),
          if (formState.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<OrderBloc, OrderState>(
              buildWhen: (p, c) => (p is OrderLoading) != (c is OrderLoading),
              builder: (context, state) {
                final isLoading = state is OrderLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : formState.currentStep == 2
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
                      : Text(
                          formState.currentStep == 2
                              ? context.l10n.confirm
                              : context.l10n.translate('next'),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
