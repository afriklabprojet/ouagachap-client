import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/support_bloc.dart';
import '../../bloc/support_event.dart';
import '../../bloc/support_state.dart';

class CreateComplaintSheet extends StatefulWidget {
  const CreateComplaintSheet({super.key});

  @override
  State<CreateComplaintSheet> createState() => _CreateComplaintSheetState();
}

class _CreateComplaintSheetState extends State<CreateComplaintSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'delivery_issue';

  final List<Map<String, String>> _types = [
    {'value': 'delivery_issue', 'label': '🚚 Problème de livraison'},
    {'value': 'payment_issue', 'label': '💰 Problème de paiement'},
    {'value': 'courier_behavior', 'label': '👤 Comportement coursier'},
    {'value': 'app_bug', 'label': '🐛 Bug application'},
    {'value': 'other', 'label': '📋 Autre'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Nouvelle réclamation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type
                    const Text(
                      'Type de réclamation',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _types.map((type) {
                        final isSelected = _selectedType == type['value'];
                        return ChoiceChip(
                          label: Text(type['label']!),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedType = type['value']!);
                          },
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Sujet
                    const Text(
                      'Sujet',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Colis non livré',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un sujet';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre problème en détail...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        if (value.trim().length < 20) {
                          return 'La description doit faire au moins 20 caractères';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: BlocConsumer<SupportBloc, SupportState>(
                listenWhen: (prev, curr) =>
                    prev.creatingComplaint &&
                    !curr.creatingComplaint &&
                    curr.currentComplaint != null,
                listener: (context, state) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Réclamation créée: #${state.currentComplaint!.ticketNumber}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.creatingComplaint
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<SupportBloc>().add(
                                  CreateComplaint(
                                    type: _selectedType,
                                    subject: _subjectController.text.trim(),
                                    description: _descriptionController.text
                                        .trim(),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.creatingComplaint
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Soumettre la réclamation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
