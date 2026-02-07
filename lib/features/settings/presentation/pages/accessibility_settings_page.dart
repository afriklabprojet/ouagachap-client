import 'package:flutter/material.dart';

import '../../../../core/services/accessibility_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Page des paramètres d'accessibilité
class AccessibilitySettingsPage extends StatefulWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  State<AccessibilitySettingsPage> createState() => _AccessibilitySettingsPageState();
}

class _AccessibilitySettingsPageState extends State<AccessibilitySettingsPage> {
  late AccessibilityService _accessibilityService;

  @override
  void initState() {
    super.initState();
    _accessibilityService = accessibilityService;
    _accessibilityService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _accessibilityService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibilité'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête explicatif
          Semantics(
            header: true,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.accessibility_new_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Personnalisez l\'application selon vos besoins',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section Affichage
          _buildSectionHeader(context, 'Affichage'),
          const SizedBox(height: 8),
          
          _buildSettingTile(
            context,
            icon: Icons.text_fields_rounded,
            title: 'Texte agrandi',
            subtitle: 'Augmente la taille du texte de 20%',
            value: _accessibilityService.largeFont,
            onChanged: (value) => _accessibilityService.setLargeFont(value),
          ),

          _buildSettingTile(
            context,
            icon: Icons.contrast_rounded,
            title: 'Contraste élevé',
            subtitle: 'Améliore la lisibilité avec des couleurs plus contrastées',
            value: _accessibilityService.highContrast,
            onChanged: (value) => _accessibilityService.setHighContrast(value),
          ),

          const SizedBox(height: 24),

          // Section Mouvement
          _buildSectionHeader(context, 'Mouvement'),
          const SizedBox(height: 8),

          _buildSettingTile(
            context,
            icon: Icons.animation_rounded,
            title: 'Réduire les animations',
            subtitle: 'Désactive les animations et transitions',
            value: _accessibilityService.reducedMotion,
            onChanged: (value) => _accessibilityService.setReducedMotion(value),
          ),

          const SizedBox(height: 24),

          // Section Lecteur d'écran
          _buildSectionHeader(context, 'Lecteur d\'écran'),
          const SizedBox(height: 8),

          _buildSettingTile(
            context,
            icon: Icons.speaker_phone_rounded,
            title: 'Optimisation lecteur d\'écran',
            subtitle: 'Améliore les descriptions vocales des éléments',
            value: _accessibilityService.screenReaderOptimized,
            onChanged: (value) => _accessibilityService.setScreenReaderOptimized(value),
          ),

          const SizedBox(height: 32),

          // Informations supplémentaires
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'À propos',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ces paramètres sont sauvegardés automatiquement et s\'appliquent immédiatement. '
                  'Vous pouvez également utiliser les options d\'accessibilité de votre appareil pour une expérience personnalisée.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  label: 'Ouvrir les paramètres d\'accessibilité du système',
                  child: TextButton.icon(
                    onPressed: () {
                      // Ouvrir les paramètres système d'accessibilité
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ouvrir Paramètres > Accessibilité sur votre appareil'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Paramètres système'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      toggled: value,
      label: '$title. $subtitle. ${value ? 'Activé' : 'Désactivé'}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : Theme.of(context).colorScheme.outline,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          onTap: () => onChanged(!value),
        ),
      ),
    );
  }
}
