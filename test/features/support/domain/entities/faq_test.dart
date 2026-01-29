import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/faq.dart';

void main() {
  group('Faq', () {
    group('constructor', () {
      test('should create Faq with required fields', () {
        const faq = Faq(
          id: 1,
          category: 'general',
          categoryLabel: 'Général',
          categoryIcon: 'help-circle',
          question: 'Comment passer une commande?',
          answer: 'Pour passer une commande...',
        );

        expect(faq.id, 1);
        expect(faq.category, 'general');
        expect(faq.categoryLabel, 'Général');
        expect(faq.categoryIcon, 'help-circle');
        expect(faq.question, 'Comment passer une commande?');
        expect(faq.answer, 'Pour passer une commande...');
        expect(faq.views, 0);
      });

      test('should create Faq with views', () {
        const faq = Faq(
          id: 2,
          category: 'payment',
          categoryLabel: 'Paiement',
          categoryIcon: 'credit-card',
          question: 'Comment payer?',
          answer: 'Vous pouvez payer par...',
          views: 150,
        );

        expect(faq.views, 150);
      });
    });

    group('fromJson', () {
      test('should create Faq from complete JSON', () {
        final json = {
          'id': 1,
          'category': 'orders',
          'category_label': 'Commandes',
          'category_icon': 'package',
          'question': 'Comment suivre ma commande?',
          'answer': 'Vous pouvez suivre votre commande...',
          'views': 250,
        };

        final faq = Faq.fromJson(json);

        expect(faq.id, 1);
        expect(faq.category, 'orders');
        expect(faq.categoryLabel, 'Commandes');
        expect(faq.categoryIcon, 'package');
        expect(faq.question, 'Comment suivre ma commande?');
        expect(faq.answer, 'Vous pouvez suivre votre commande...');
        expect(faq.views, 250);
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};

        final faq = Faq.fromJson(json);

        expect(faq.id, 0);
        expect(faq.category, 'general');
        expect(faq.categoryLabel, 'Général');
        expect(faq.categoryIcon, 'help-circle');
        expect(faq.question, '');
        expect(faq.answer, '');
        expect(faq.views, 0);
      });

      test('should handle partial JSON', () {
        final json = {
          'id': 5,
          'question': 'Partial question',
        };

        final faq = Faq.fromJson(json);

        expect(faq.id, 5);
        expect(faq.question, 'Partial question');
        expect(faq.category, 'general');
        expect(faq.categoryLabel, 'Général');
      });
    });

    group('Equatable', () {
      test('props should contain id, category, question, answer, views', () {
        const faq = Faq(
          id: 1,
          category: 'general',
          categoryLabel: 'Général',
          categoryIcon: 'help-circle',
          question: 'Test question',
          answer: 'Test answer',
          views: 10,
        );

        expect(faq.props, [1, 'general', 'Test question', 'Test answer', 10]);
      });

      test('two faqs with same props should be equal', () {
        const faq1 = Faq(
          id: 1,
          category: 'general',
          categoryLabel: 'Général',
          categoryIcon: 'help-circle',
          question: 'Question',
          answer: 'Answer',
          views: 5,
        );
        const faq2 = Faq(
          id: 1,
          category: 'general',
          categoryLabel: 'Different Label',
          categoryIcon: 'different-icon',
          question: 'Question',
          answer: 'Answer',
          views: 5,
        );

        expect(faq1, equals(faq2));
      });

      test('two faqs with different id should not be equal', () {
        const faq1 = Faq(
          id: 1,
          category: 'general',
          categoryLabel: 'Général',
          categoryIcon: 'help-circle',
          question: 'Question',
          answer: 'Answer',
        );
        const faq2 = Faq(
          id: 2,
          category: 'general',
          categoryLabel: 'Général',
          categoryIcon: 'help-circle',
          question: 'Question',
          answer: 'Answer',
        );

        expect(faq1, isNot(equals(faq2)));
      });
    });

    group('different categories', () {
      test('should handle general category', () {
        const faq = Faq(
          id: 1,
          category: 'general',
          categoryLabel: 'Général',
          categoryIcon: 'help-circle',
          question: 'Q',
          answer: 'A',
        );
        expect(faq.category, 'general');
      });

      test('should handle orders category', () {
        const faq = Faq(
          id: 2,
          category: 'orders',
          categoryLabel: 'Commandes',
          categoryIcon: 'package',
          question: 'Q',
          answer: 'A',
        );
        expect(faq.category, 'orders');
      });

      test('should handle payment category', () {
        const faq = Faq(
          id: 3,
          category: 'payment',
          categoryLabel: 'Paiement',
          categoryIcon: 'credit-card',
          question: 'Q',
          answer: 'A',
        );
        expect(faq.category, 'payment');
      });

      test('should handle delivery category', () {
        const faq = Faq(
          id: 4,
          category: 'delivery',
          categoryLabel: 'Livraison',
          categoryIcon: 'truck',
          question: 'Q',
          answer: 'A',
        );
        expect(faq.category, 'delivery');
      });

      test('should handle wallet category', () {
        const faq = Faq(
          id: 5,
          category: 'wallet',
          categoryLabel: 'Portefeuille',
          categoryIcon: 'wallet',
          question: 'Q',
          answer: 'A',
        );
        expect(faq.category, 'wallet');
      });
    });
  });

  group('FaqCategories', () {
    test('should contain all expected categories', () {
      expect(FaqCategories.all, containsPair('all', '📚 Toutes'));
      expect(FaqCategories.all, containsPair('general', '📋 Général'));
      expect(FaqCategories.all, containsPair('orders', '📦 Commandes'));
      expect(FaqCategories.all, containsPair('payment', '💰 Paiement'));
      expect(FaqCategories.all, containsPair('delivery', '🚚 Livraison'));
      expect(FaqCategories.all, containsPair('account', '👤 Compte'));
      expect(FaqCategories.all, containsPair('wallet', '💳 Portefeuille'));
    });

    test('getLabel should return label for known category', () {
      expect(FaqCategories.getLabel('general'), '📋 Général');
      expect(FaqCategories.getLabel('orders'), '📦 Commandes');
      expect(FaqCategories.getLabel('payment'), '💰 Paiement');
    });

    test('getLabel should return category itself for unknown category', () {
      expect(FaqCategories.getLabel('unknown'), 'unknown');
      expect(FaqCategories.getLabel('custom'), 'custom');
    });

    test('should have 7 categories total', () {
      expect(FaqCategories.all.length, 7);
    });
  });
}
