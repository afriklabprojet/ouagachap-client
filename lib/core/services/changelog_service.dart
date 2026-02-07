import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour afficher les nouveautés après mise à jour
class ChangelogService {
  final SharedPreferences _prefs;

  static const String _keyLastSeenVersion = 'changelog_last_seen';
  
  // Version actuelle de l'app (à mettre à jour à chaque release)
  static const String currentVersion = '1.0.0';

  ChangelogService(this._prefs);

  /// Vérifie si on doit afficher le changelog
  bool shouldShowChangelog() {
    final lastSeen = _prefs.getString(_keyLastSeenVersion);
    
    // Première installation
    if (lastSeen == null) {
      return false; // Ne pas montrer à la première installation
    }
    
    // Nouvelle version
    return lastSeen != currentVersion;
  }

  /// Marque le changelog comme vu
  Future<void> markAsSeen() async {
    await _prefs.setString(_keyLastSeenVersion, currentVersion);
  }

  /// Récupère le changelog de la version actuelle
  ChangelogData getCurrentChangelog() {
    return changelogs[currentVersion] ?? ChangelogData(
      version: currentVersion,
      date: DateTime.now(),
      title: 'Nouvelle version',
      features: [],
    );
  }

  /// Récupère tous les changelogs
  List<ChangelogData> getAllChangelogs() {
    return changelogs.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Affiche le dialog de changelog
  Future<void> showChangelogDialog(BuildContext context) async {
    final changelog = getCurrentChangelog();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangelogDialog(
        changelog: changelog,
        onDismiss: () {
          markAsSeen();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Enregistre la version actuelle (à appeler au premier lancement)
  Future<void> registerCurrentVersion() async {
    final lastSeen = _prefs.getString(_keyLastSeenVersion);
    if (lastSeen == null) {
      await _prefs.setString(_keyLastSeenVersion, currentVersion);
    }
  }
}

/// Données d'un changelog
class ChangelogData {
  final String version;
  final DateTime date;
  final String title;
  final List<ChangelogItem> features;
  final List<ChangelogItem>? improvements;
  final List<ChangelogItem>? bugfixes;

  ChangelogData({
    required this.version,
    required this.date,
    required this.title,
    required this.features,
    this.improvements,
    this.bugfixes,
  });
}

/// Item de changelog
class ChangelogItem {
  final IconData icon;
  final String title;
  final String? description;

  ChangelogItem({
    required this.icon,
    required this.title,
    this.description,
  });
}

/// Dialog de changelog
class ChangelogDialog extends StatelessWidget {
  final ChangelogData changelog;
  final VoidCallback onDismiss;

  const ChangelogDialog({
    super.key,
    required this.changelog,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          const Icon(Icons.celebration, size: 48, color: Colors.orange),
          const SizedBox(height: 12),
          Text(
            changelog.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Version ${changelog.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (changelog.features.isNotEmpty) ...[
              _buildSection(context, '🆕 Nouveautés', changelog.features),
            ],
            if (changelog.improvements != null && changelog.improvements!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(context, '⚡ Améliorations', changelog.improvements!),
            ],
            if (changelog.bugfixes != null && changelog.bugfixes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(context, '🐛 Corrections', changelog.bugfixes!),
            ],
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDismiss,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'C\'est parti !',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<ChangelogItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

// ==================== CHANGELOGS ====================
// Ajouter ici les changelogs de chaque version

final Map<String, ChangelogData> changelogs = {
  '1.0.0': ChangelogData(
    version: '1.0.0',
    date: DateTime(2026, 2, 1),
    title: 'Bienvenue sur OUAGA CHAP ! 🎉',
    features: [
      ChangelogItem(
        icon: Icons.local_shipping,
        title: 'Livraison rapide',
        description: 'Envoyez vos colis partout à Ouagadougou',
      ),
      ChangelogItem(
        icon: Icons.location_on,
        title: 'Suivi en temps réel',
        description: 'Suivez votre coursier sur la carte',
      ),
      ChangelogItem(
        icon: Icons.payment,
        title: 'Paiement mobile money',
        description: 'Orange Money, Moov Money, Coris Money',
      ),
      ChangelogItem(
        icon: Icons.bookmark,
        title: 'Carnet d\'adresses',
        description: 'Sauvegardez vos adresses favorites',
      ),
    ],
  ),
  
  // Exemple pour la prochaine version
  // '1.1.0': ChangelogData(
  //   version: '1.1.0',
  //   date: DateTime(2026, 3, 1),
  //   title: 'Nouvelles fonctionnalités !',
  //   features: [
  //     ChangelogItem(
  //       icon: Icons.notifications,
  //       title: 'Notifications push',
  //       description: 'Soyez alerté en temps réel',
  //     ),
  //   ],
  //   improvements: [
  //     ChangelogItem(
  //       icon: Icons.speed,
  //       title: 'Performance améliorée',
  //     ),
  //   ],
  //   bugfixes: [
  //     ChangelogItem(
  //       icon: Icons.bug_report,
  //       title: 'Correction de bugs mineurs',
  //     ),
  //   ],
  // ),
};
