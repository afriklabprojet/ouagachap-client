import 'package:equatable/equatable.dart';

/// Modèle pour une FAQ
class Faq extends Equatable {
  final int id;
  final String category;
  final String categoryLabel;
  final String categoryIcon;
  final String question;
  final String answer;
  final int views;

  const Faq({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.question,
    required this.answer,
    this.views = 0,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] ?? 0,
      category: json['category'] ?? 'general',
      categoryLabel: json['category_label'] ?? 'Général',
      categoryIcon: json['category_icon'] ?? 'help-circle',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      views: json['views'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, category, question, answer, views];
}

/// Liste des catégories de FAQ
class FaqCategories {
  static const Map<String, String> all = {
    'all': '📚 Toutes',
    'general': '📋 Général',
    'orders': '📦 Commandes',
    'payment': '💰 Paiement',
    'delivery': '🚚 Livraison',
    'account': '👤 Compte',
    'wallet': '💳 Portefeuille',
  };

  static String getLabel(String category) => all[category] ?? category;
}
