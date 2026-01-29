import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final Function(int rating, String? review, List<String> tags) onSubmit;
  final String courierName;

  const RatingDialog({
    Key? key,
    required this.onSubmit,
    required this.courierName,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  // Tags prédéfinis (correspond aux constants du backend)
  static const Map<String, String> positiveTags = {
    'rapide': 'Rapide',
    'professionnel': 'Professionnel',
    'aimable': 'Aimable',
    'ponctuel': 'Ponctuel',
    'soigneux': 'Soigneux',
    'communicatif': 'Bonne communication',
  };

  static const Map<String, String> negativeTags = {
    'lent': 'Lent',
    'impoli': 'Impoli',
    'retard': 'En retard',
    'colis_abime': 'Colis abîmé',
    'difficile_joindre': 'Difficile à joindre',
  };

  Map<String, String> get _availableTags {
    if (_rating >= 4) {
      return positiveTags;
    } else if (_rating <= 2) {
      return negativeTags;
    }
    return {};
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    widget.onSubmit(_rating, _reviewController.text.trim(), _selectedTags.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              Text(
                'Noter le coursier',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.courierName,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Étoiles
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return GestureDetector(
                    onTap: _isSubmitting ? null : () {
                      setState(() {
                        _rating = starValue;
                        _selectedTags.clear(); // Reset tags on rating change
                      });
                    },
                    child: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: starValue <= _rating
                          ? Colors.amber
                          : Colors.grey[400],
                    ),
                  );
                }),
              ),
              if (_rating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _getRatingLabel(_rating),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // Tags rapides
              if (_availableTags.isNotEmpty) ...[
                Text(
                  'Sélectionnez des tags (optionnel)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.entries.map((entry) {
                    final isSelected = _selectedTags.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: _isSubmitting ? null : (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(entry.key);
                          } else {
                            _selectedTags.remove(entry.key);
                          }
                        });
                      },
                      selectedColor: _rating >= 4
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Commentaire
              TextField(
                controller: _reviewController,
                enabled: !_isSubmitting,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  hintText: 'Partagez votre expérience...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Très mauvais';
      case 2:
        return 'Mauvais';
      case 3:
        return 'Moyen';
      case 4:
        return 'Bon';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
