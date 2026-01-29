import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/contact_info.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/faq.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/support_chat.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/complaint.dart';
import 'package:ouaga_chap_client/features/support/presentation/bloc/support_state.dart';

void main() {
  group('SupportStatus', () {
    test('has all expected values', () {
      expect(SupportStatus.values.length, 4);
      expect(SupportStatus.values, contains(SupportStatus.initial));
      expect(SupportStatus.values, contains(SupportStatus.loading));
      expect(SupportStatus.values, contains(SupportStatus.success));
      expect(SupportStatus.values, contains(SupportStatus.failure));
    });
  });

  group('SupportState', () {
    group('Constructor', () {
      test('creates default state', () {
        const state = SupportState();

        expect(state.status, SupportStatus.initial);
        expect(state.errorMessage, isNull);
        expect(state.contactInfo, isNull);
        expect(state.faqs, isEmpty);
        expect(state.selectedFaqCategory, 'all');
        expect(state.faqSearchQuery, '');
        expect(state.faqsLoading, isFalse);
        expect(state.chats, isEmpty);
        expect(state.currentChat, isNull);
        expect(state.chatMessages, isEmpty);
        expect(state.chatLoading, isFalse);
        expect(state.sendingMessage, isFalse);
        expect(state.complaints, isEmpty);
        expect(state.currentComplaint, isNull);
        expect(state.complaintMessages, isEmpty);
        expect(state.complaintsLoading, isFalse);
        expect(state.creatingComplaint, isFalse);
      });

      test('creates state with custom values', () {
        final contactInfo = ContactInfo(
          phone: '123',
          phoneDisplay: '+226 123',
          email: 'test@test.com',
          whatsapp: '123',
          whatsappMessage: 'Bonjour',
          workingHours: const WorkingHours(days: 'Lun-Ven', hours: '9h-18h'),
          social: const SocialLinks(facebook: 'fb', instagram: 'ig', twitter: 'tw'),
          address: const Address(street: 'Rue 1', city: 'Ouaga', country: 'Burkina'),
        );

        final state = SupportState(
          status: SupportStatus.success,
          errorMessage: 'Error',
          contactInfo: contactInfo,
          selectedFaqCategory: 'orders',
          faqSearchQuery: 'search',
          faqsLoading: true,
          chatLoading: true,
          sendingMessage: true,
          complaintsLoading: true,
          creatingComplaint: true,
        );

        expect(state.status, SupportStatus.success);
        expect(state.errorMessage, 'Error');
        expect(state.contactInfo, contactInfo);
        expect(state.selectedFaqCategory, 'orders');
        expect(state.faqSearchQuery, 'search');
        expect(state.faqsLoading, isTrue);
        expect(state.chatLoading, isTrue);
        expect(state.sendingMessage, isTrue);
        expect(state.complaintsLoading, isTrue);
        expect(state.creatingComplaint, isTrue);
      });
    });

    group('hasOpenChat getter', () {
      test('returns false when chats is empty', () {
        const state = SupportState();
        expect(state.hasOpenChat, isFalse);
      });

      test('returns true when there is an open chat', () {
        final openChat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime.now(),
        );

        final state = SupportState(chats: [openChat]);
        expect(state.hasOpenChat, isTrue);
      });

      test('returns false when all chats are closed', () {
        final closedChat = SupportChat(
          id: 1,
          status: 'closed',
          statusLabel: 'Fermée',
          createdAt: DateTime.now(),
        );

        final state = SupportState(chats: [closedChat]);
        expect(state.hasOpenChat, isFalse);
      });
    });

    group('totalUnreadMessages getter', () {
      test('returns 0 when no unread messages', () {
        const state = SupportState();
        expect(state.totalUnreadMessages, 0);
      });

      test('sums unread from chats', () {
        final chat1 = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 3,
          createdAt: DateTime.now(),
        );
        final chat2 = SupportChat(
          id: 2,
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 5,
          createdAt: DateTime.now(),
        );

        final state = SupportState(chats: [chat1, chat2]);
        expect(state.totalUnreadMessages, 8);
      });

      test('sums unread from complaints', () {
        final complaint1 = Complaint(
          id: 1,
          ticketNumber: 'TK001',
          type: 'order',
          typeLabel: 'Commande',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'green',
          statusLabel: 'Ouverte',
          priority: 'medium',
          priorityColor: 'orange',
          priorityLabel: 'Moyenne',
          unreadCount: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final complaint2 = Complaint(
          id: 2,
          ticketNumber: 'TK002',
          type: 'order',
          typeLabel: 'Commande',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'green',
          statusLabel: 'Ouverte',
          priority: 'medium',
          priorityColor: 'orange',
          priorityLabel: 'Moyenne',
          unreadCount: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final state = SupportState(complaints: [complaint1, complaint2]);
        expect(state.totalUnreadMessages, 6);
      });

      test('sums unread from both chats and complaints', () {
        final chat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 3,
          createdAt: DateTime.now(),
        );
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TK001',
          type: 'order',
          typeLabel: 'Commande',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'green',
          statusLabel: 'Ouverte',
          priority: 'medium',
          priorityColor: 'orange',
          priorityLabel: 'Moyenne',
          unreadCount: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final state = SupportState(chats: [chat], complaints: [complaint]);
        expect(state.totalUnreadMessages, 5);
      });
    });

    group('copyWith', () {
      test('returns same state when no parameters', () {
        const state = SupportState(
          status: SupportStatus.success,
          selectedFaqCategory: 'orders',
        );

        final copied = state.copyWith();

        expect(copied.status, SupportStatus.success);
        expect(copied.selectedFaqCategory, 'orders');
      });

      test('updates status', () {
        const state = SupportState();
        final copied = state.copyWith(status: SupportStatus.loading);
        expect(copied.status, SupportStatus.loading);
      });

      test('updates errorMessage', () {
        const state = SupportState();
        final copied = state.copyWith(errorMessage: 'Error occurred');
        expect(copied.errorMessage, 'Error occurred');
      });

      test('clears errorMessage when clearError is true', () {
        const state = SupportState(errorMessage: 'Error');
        final copied = state.copyWith(clearError: true);
        expect(copied.errorMessage, isNull);
      });

      test('updates contactInfo', () {
        const state = SupportState();
        final contactInfo = ContactInfo(
          phone: '123',
          phoneDisplay: '+226 123',
          email: 'test@test.com',
          whatsapp: '123',
          whatsappMessage: 'Bonjour',
          workingHours: const WorkingHours(days: 'Lun-Ven', hours: '9h-18h'),
          social: const SocialLinks(facebook: 'fb', instagram: 'ig', twitter: 'tw'),
          address: const Address(street: 'Rue 1', city: 'Ouaga', country: 'Burkina'),
        );
        final copied = state.copyWith(contactInfo: contactInfo);
        expect(copied.contactInfo, contactInfo);
      });

      test('updates faqs', () {
        const state = SupportState();
        final faqs = [
          Faq(
            id: 1,
            category: 'orders',
            categoryLabel: 'Commandes',
            categoryIcon: 'shopping_cart',
            question: 'Q?',
            answer: 'A',
          ),
        ];
        final copied = state.copyWith(faqs: faqs);
        expect(copied.faqs, faqs);
      });

      test('updates selectedFaqCategory', () {
        const state = SupportState();
        final copied = state.copyWith(selectedFaqCategory: 'payments');
        expect(copied.selectedFaqCategory, 'payments');
      });

      test('updates faqSearchQuery', () {
        const state = SupportState();
        final copied = state.copyWith(faqSearchQuery: 'search');
        expect(copied.faqSearchQuery, 'search');
      });

      test('updates faqsLoading', () {
        const state = SupportState();
        final copied = state.copyWith(faqsLoading: true);
        expect(copied.faqsLoading, isTrue);
      });

      test('updates chats', () {
        const state = SupportState();
        final chats = [
          SupportChat(
            id: 1,
            status: 'open',
            statusLabel: 'Ouverte',
            createdAt: DateTime.now(),
          ),
        ];
        final copied = state.copyWith(chats: chats);
        expect(copied.chats, chats);
      });

      test('updates currentChat', () {
        const state = SupportState();
        final currentChat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime.now(),
        );
        final copied = state.copyWith(currentChat: currentChat);
        expect(copied.currentChat, currentChat);
      });

      test('clears currentChat when clearCurrentChat is true', () {
        final currentChat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime.now(),
        );
        final state = SupportState(currentChat: currentChat);
        final copied = state.copyWith(clearCurrentChat: true);
        expect(copied.currentChat, isNull);
      });

      test('updates chatMessages', () {
        const state = SupportState();
        final messages = [
          ChatMessage(
            id: 1,
            message: 'Hello',
            isAdmin: false,
            isRead: true,
            createdAt: DateTime.now(),
          ),
        ];
        final copied = state.copyWith(chatMessages: messages);
        expect(copied.chatMessages, messages);
      });

      test('updates chatLoading', () {
        const state = SupportState();
        final copied = state.copyWith(chatLoading: true);
        expect(copied.chatLoading, isTrue);
      });

      test('updates sendingMessage', () {
        const state = SupportState();
        final copied = state.copyWith(sendingMessage: true);
        expect(copied.sendingMessage, isTrue);
      });

      test('updates complaints', () {
        const state = SupportState();
        final complaints = [
          Complaint(
            id: 1,
            ticketNumber: 'TK001',
            type: 'order',
            typeLabel: 'Commande',
            subject: 'Test',
            description: 'Test',
            status: 'open',
            statusColor: 'green',
            statusLabel: 'Ouverte',
            priority: 'medium',
            priorityColor: 'orange',
            priorityLabel: 'Moyenne',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final copied = state.copyWith(complaints: complaints);
        expect(copied.complaints, complaints);
      });

      test('updates currentComplaint', () {
        const state = SupportState();
        final currentComplaint = Complaint(
          id: 1,
          ticketNumber: 'TK001',
          type: 'order',
          typeLabel: 'Commande',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'green',
          statusLabel: 'Ouverte',
          priority: 'medium',
          priorityColor: 'orange',
          priorityLabel: 'Moyenne',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final copied = state.copyWith(currentComplaint: currentComplaint);
        expect(copied.currentComplaint, currentComplaint);
      });

      test('clears currentComplaint when clearCurrentComplaint is true', () {
        final currentComplaint = Complaint(
          id: 1,
          ticketNumber: 'TK001',
          type: 'order',
          typeLabel: 'Commande',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'green',
          statusLabel: 'Ouverte',
          priority: 'medium',
          priorityColor: 'orange',
          priorityLabel: 'Moyenne',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final state = SupportState(currentComplaint: currentComplaint);
        final copied = state.copyWith(clearCurrentComplaint: true);
        expect(copied.currentComplaint, isNull);
      });

      test('updates complaintMessages', () {
        const state = SupportState();
        final messages = <ComplaintMessage>[
          ComplaintMessage(
            id: 1,
            message: 'Hello',
            isAdmin: false,
            isRead: true,
            createdAt: DateTime.now(),
          ),
        ];
        final copied = state.copyWith(complaintMessages: messages);
        expect(copied.complaintMessages, messages);
      });

      test('updates complaintsLoading', () {
        const state = SupportState();
        final copied = state.copyWith(complaintsLoading: true);
        expect(copied.complaintsLoading, isTrue);
      });

      test('updates creatingComplaint', () {
        const state = SupportState();
        final copied = state.copyWith(creatingComplaint: true);
        expect(copied.creatingComplaint, isTrue);
      });
    });

    group('Equatable', () {
      test('two states with same props are equal', () {
        const state1 = SupportState(
          status: SupportStatus.success,
          selectedFaqCategory: 'orders',
        );
        const state2 = SupportState(
          status: SupportStatus.success,
          selectedFaqCategory: 'orders',
        );

        expect(state1, equals(state2));
      });

      test('two states with different props are not equal', () {
        const state1 = SupportState(status: SupportStatus.initial);
        const state2 = SupportState(status: SupportStatus.loading);

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
