import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../domain/entities/saved_address.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(const LoadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mes adresses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
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
          if (state.status == AddressStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.addresses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AddressBloc>().add(const LoadAddresses());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length,
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return SlideInWidget(
                  delay: Duration(milliseconds: 50 * index),
                  child: _buildAddressCard(address, state.isDeleting),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucune adresse sauvegardée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez vos adresses favorites pour passer commande plus rapidement',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddAddressSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une adresse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(SavedAddress address, bool isDeleting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: address.isDefault
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showAddressOptions(address),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor(address.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    address.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
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
                            fontSize: 16,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Par défaut',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
                    if (address.contactName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${address.contactName}${address.contactPhone != null ? ' • ${address.contactPhone}' : ''}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // More icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Colors.blue;
      case AddressType.work:
        return Colors.orange;
      case AddressType.other:
        return AppColors.primary;
    }
  }

  void _showAddressOptions(SavedAddress address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                address.displayLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address.address,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              if (!address.isDefault)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star, color: AppColors.primary),
                  ),
                  title: const Text('Définir par défaut'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AddressBloc>().add(SetDefaultAddress(address.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adresse définie par défaut'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditAddressSheet(context, address);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(address);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(SavedAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'adresse ?'),
        content: Text('Voulez-vous vraiment supprimer "${address.label}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddressBloc>().add(DeleteAddress(address.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Adresse supprimée'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context, [SavedAddress? editAddress]) {
    _showEditAddressSheet(context, editAddress);
  }

  void _showEditAddressSheet(BuildContext context, SavedAddress? address) {
    final isEditing = address != null;
    final labelController = TextEditingController(text: address?.label);
    final addressController = TextEditingController(text: address?.address);
    final contactNameController = TextEditingController(text: address?.contactName);
    final contactPhoneController = TextEditingController(text: address?.contactPhone);
    final instructionsController = TextEditingController(text: address?.instructions);
    String selectedType = address?.type.name ?? 'other';
    bool isDefault = address?.isDefault ?? false;

    // Mock coordinates for Ouagadougou (in real app, use geocoding or map picker)
    double latitude = address?.latitude ?? 12.3714;
    double longitude = address?.longitude ?? -1.5197;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Modifier l\'adresse' : 'Nouvelle adresse',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Type selector
                  const Text('Type d\'adresse', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypeChip('home', '🏠 Maison', selectedType, (type) {
                        setSheetState(() => selectedType = type);
                      }),
                      const SizedBox(width: 8),
                      _buildTypeChip('work', '🏢 Bureau', selectedType, (type) {
                        setSheetState(() => selectedType = type);
                      }),
                      const SizedBox(width: 8),
                      _buildTypeChip('other', '📍 Autre', selectedType, (type) {
                        setSheetState(() => selectedType = type);
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Label
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'adresse *',
                      hintText: 'Ex: Maison, Bureau, Chez Maman...',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Adresse complète *',
                      hintText: 'Ex: Quartier Patte d\'oie, Secteur 15',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact info
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Contact sur place (optionnel)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du contact',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactPhoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      hintText: '70 00 00 00',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+226 ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instructionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      hintText: 'Ex: Portail bleu, 2ème étage...',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Default checkbox
                  CheckboxListTile(
                    value: isDefault,
                    onChanged: (value) {
                      setSheetState(() => isDefault = value ?? false);
                    },
                    title: const Text('Définir comme adresse par défaut'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isCreating
                              ? null
                              : () {
                                  if (labelController.text.isEmpty ||
                                      addressController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Veuillez remplir les champs obligatoires'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  if (isEditing) {
                                    context.read<AddressBloc>().add(UpdateAddress(
                                          id: address!.id,
                                          label: labelController.text,
                                          address: addressController.text,
                                          latitude: latitude,
                                          longitude: longitude,
                                          contactName: contactNameController.text.isEmpty
                                              ? null
                                              : contactNameController.text,
                                          contactPhone: contactPhoneController.text.isEmpty
                                              ? null
                                              : '+226${contactPhoneController.text}',
                                          instructions: instructionsController.text.isEmpty
                                              ? null
                                              : instructionsController.text,
                                          isDefault: isDefault,
                                          type: selectedType,
                                        ));
                                  } else {
                                    context.read<AddressBloc>().add(CreateAddress(
                                          label: labelController.text,
                                          address: addressController.text,
                                          latitude: latitude,
                                          longitude: longitude,
                                          contactName: contactNameController.text.isEmpty
                                              ? null
                                              : contactNameController.text,
                                          contactPhone: contactPhoneController.text.isEmpty
                                              ? null
                                              : '+226${contactPhoneController.text}',
                                          instructions: instructionsController.text.isEmpty
                                              ? null
                                              : instructionsController.text,
                                          isDefault: isDefault,
                                          type: selectedType,
                                        ));
                                  }

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEditing
                                          ? 'Adresse mise à jour'
                                          : 'Adresse ajoutée'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: state.isCreating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? 'Mettre à jour' : 'Enregistrer'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String type,
    String label,
    String selectedType,
    Function(String) onSelect,
  ) {
    final isSelected = type == selectedType;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
