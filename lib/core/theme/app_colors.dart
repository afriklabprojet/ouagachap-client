import 'package:flutter/material.dart';

/// Couleurs de l'application OUAGA CHAP - Client
/// Charte graphique officielle : Rouge et Jaune
class AppColors {
  AppColors._();

  // ==========================================================================
  // COULEURS PRINCIPALES - OUAGA CHAP
  // ==========================================================================
  
  /// Rouge OUAGA CHAP - Couleur principale
  static const Color primary = Color(0xFFE31E24);
  static const Color primaryLight = Color(0xFFFF5252);
  static const Color primaryDark = Color(0xFFB71C1C);
  
  /// Jaune OUAGA CHAP - Couleur secondaire/accent
  static const Color secondary = Color(0xFFF7C72C);
  static const Color secondaryLight = Color(0xFFFFE082);
  static const Color secondaryDark = Color(0xFFF9A825);
  
  /// Couleur d'accent (jaune pour les éléments interactifs)
  static const Color accent = Color(0xFFF7C72C);
  
  // ==========================================================================
  // COULEURS DE FOND
  // ==========================================================================
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // ==========================================================================
  // COULEURS DE TEXTE
  // ==========================================================================
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1E293B); // Texte sur jaune
  
  // ==========================================================================
  // COULEURS DE STATUT
  // ==========================================================================
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // ==========================================================================
  // COULEURS DES STATUTS DE COMMANDE
  // ==========================================================================
  static const Color statusPending = Color(0xFFF7C72C);      // Jaune - En attente
  static const Color statusAccepted = Color(0xFF3B82F6);     // Bleu - Acceptée
  static const Color statusPickedUp = Color(0xFF8B5CF6);     // Violet - Récupérée
  static const Color statusInTransit = Color(0xFFE31E24);    // Rouge - En transit
  static const Color statusDelivered = Color(0xFF10B981);    // Vert - Livrée
  static const Color statusCancelled = Color(0xFF6B7280);    // Gris - Annulée
  
  // ==========================================================================
  // COULEURS DE BORDURE ET OMBRE
  // ==========================================================================
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x1A000000);
  
  // ==========================================================================
  // DÉGRADÉS OUAGA CHAP
  // ==========================================================================
  
  /// Dégradé principal (rouge)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  /// Dégradé secondaire (jaune)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );
  
  /// Dégradé hero (rouge vers rouge foncé)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
  
  /// Dégradé splash/login (rouge et jaune)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
