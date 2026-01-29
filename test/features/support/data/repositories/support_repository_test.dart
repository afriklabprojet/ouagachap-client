import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/support/data/datasources/support_remote_datasource.dart';
import 'package:ouaga_chap_client/features/support/data/repositories/support_repository.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/contact_info.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/faq.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/support_chat.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/complaint.dart';

class MockSupportRemoteDataSource extends Mock
    implements SupportRemoteDataSource {}

void main() {
  late SupportRepository repository;
  late MockSupportRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSupportRemoteDataSource();
    repository = SupportRepository(mockDataSource);
  });

  group('SupportRepository', () {
    group('getContactInfo', () {
      test('returns contact info from datasource', () async {
        final contactInfo = ContactInfo(
          phone: '+226 25 00 00 00',
          phoneDisplay: '25 00 00 00',
          email: 'support@ouaga.chap',
          whatsapp: '22670000000',
          whatsappMessage: 'Bonjour',
          workingHours: const WorkingHours(
            days: 'Lun-Ven',
            hours: '8h-18h',
          ),
          social: const SocialLinks(
            facebook: 'fb.com/ouagachap',
            twitter: '@ouagachap',
            instagram: '@ouagachap',
          ),
          address: const Address(
            street: 'Rue principale',
            city: 'Ouagadougou',
            country: 'Burkina Faso',
          ),
        );

        when(() => mockDataSource.getContactInfo())
            .thenAnswer((_) async => contactInfo);

        final result = await repository.getContactInfo();

        expect(result, contactInfo);
        verify(() => mockDataSource.getContactInfo()).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.getContactInfo())
            .thenThrow(Exception('Error'));

        expect(
          () => repository.getContactInfo(),
          throwsException,
        );
      });
    });

    group('getFaqs', () {
      test('returns faqs without filters', () async {
        final faqs = [
          const Faq(
            id: 1,
            category: 'general',
            categoryLabel: 'Général',
            categoryIcon: 'help',
            question: 'Comment ça marche?',
            answer: 'Réponse...',
          ),
        ];

        when(() => mockDataSource.getFaqs())
            .thenAnswer((_) async => faqs);

        final result = await repository.getFaqs();

        expect(result, faqs);
        verify(() => mockDataSource.getFaqs()).called(1);
      });

      test('returns faqs with category filter', () async {
        final faqs = <Faq>[];

        when(() => mockDataSource.getFaqs(category: 'payment'))
            .thenAnswer((_) async => faqs);

        final result = await repository.getFaqs(category: 'payment');

        expect(result, faqs);
        verify(() => mockDataSource.getFaqs(category: 'payment')).called(1);
      });

      test('returns faqs with search filter', () async {
        final faqs = <Faq>[];

        when(() => mockDataSource.getFaqs(search: 'paiement'))
            .thenAnswer((_) async => faqs);

        final result = await repository.getFaqs(search: 'paiement');

        expect(result, faqs);
        verify(() => mockDataSource.getFaqs(search: 'paiement')).called(1);
      });

      test('returns faqs with both filters', () async {
        final faqs = <Faq>[];

        when(() => mockDataSource.getFaqs(category: 'payment', search: 'mobile'))
            .thenAnswer((_) async => faqs);

        final result = await repository.getFaqs(category: 'payment', search: 'mobile');

        expect(result, faqs);
        verify(() => mockDataSource.getFaqs(category: 'payment', search: 'mobile')).called(1);
      });
    });

    group('viewFaq', () {
      test('calls datasource with faqId', () async {
        when(() => mockDataSource.viewFaq(1))
            .thenAnswer((_) async {});

        await repository.viewFaq(1);

        verify(() => mockDataSource.viewFaq(1)).called(1);
      });
    });

    group('getChats', () {
      test('returns chats from datasource', () async {
        final chats = [
          SupportChat(
            id: 1,
            subject: 'Help',
            status: 'open',
            statusLabel: 'Ouvert',
            unreadCount: 2,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        when(() => mockDataSource.getChats())
            .thenAnswer((_) async => chats);

        final result = await repository.getChats();

        expect(result, chats);
        verify(() => mockDataSource.getChats()).called(1);
      });
    });

    group('getOrCreateChat', () {
      test('creates chat without subject', () async {
        final chat = SupportChat(
          id: 1,
          subject: 'Nouvelle conversation',
          status: 'open',
          statusLabel: 'Ouvert',
          unreadCount: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.getOrCreateChat())
            .thenAnswer((_) async => chat);

        final result = await repository.getOrCreateChat();

        expect(result, chat);
        verify(() => mockDataSource.getOrCreateChat()).called(1);
      });

      test('creates chat with subject', () async {
        final chat = SupportChat(
          id: 2,
          subject: 'Problème de livraison',
          status: 'open',
          statusLabel: 'Ouvert',
          unreadCount: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.getOrCreateChat(subject: 'Problème de livraison'))
            .thenAnswer((_) async => chat);

        final result = await repository.getOrCreateChat(subject: 'Problème de livraison');

        expect(result, chat);
        verify(() => mockDataSource.getOrCreateChat(subject: 'Problème de livraison')).called(1);
      });
    });

    group('getChatMessages', () {
      test('returns messages for chatId', () async {
        final messages = [
          ChatMessage(
            id: 1,
            message: 'Bonjour',
            isAdmin: false,
            isRead: true,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        when(() => mockDataSource.getChatMessages(1))
            .thenAnswer((_) async => messages);

        final result = await repository.getChatMessages(1);

        expect(result, messages);
        verify(() => mockDataSource.getChatMessages(1)).called(1);
      });
    });

    group('sendChatMessage', () {
      test('sends message and returns response', () async {
        final message = ChatMessage(
          id: 2,
          message: 'Mon message',
          isAdmin: false,
          isRead: false,
          createdAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.sendChatMessage(1, 'Mon message'))
            .thenAnswer((_) async => message);

        final result = await repository.sendChatMessage(1, 'Mon message');

        expect(result, message);
        verify(() => mockDataSource.sendChatMessage(1, 'Mon message')).called(1);
      });
    });

    group('closeChat', () {
      test('closes chat and returns updated chat', () async {
        final closedChat = SupportChat(
          id: 1,
          subject: 'Help',
          status: 'closed',
          statusLabel: 'Fermé',
          unreadCount: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.closeChat(1))
            .thenAnswer((_) async => closedChat);

        final result = await repository.closeChat(1);

        expect(result.status, 'closed');
        verify(() => mockDataSource.closeChat(1)).called(1);
      });
    });

    group('getComplaints', () {
      test('returns complaints from datasource', () async {
        final complaints = [
          Complaint(
            id: 1,
            ticketNumber: 'TKT001',
            type: 'delivery',
            typeLabel: 'Livraison',
            subject: 'Retard',
            description: 'Description...',
            status: 'open',
            statusLabel: 'Ouvert',
            statusColor: '#00FF00',
            priority: 'medium',
            priorityLabel: 'Moyen',
            priorityColor: '#FFA500',
            createdAt: DateTime(2024, 1, 15),
            updatedAt: DateTime(2024, 1, 15),
          ),
        ];

        when(() => mockDataSource.getComplaints())
            .thenAnswer((_) async => complaints);

        final result = await repository.getComplaints();

        expect(result, complaints);
        verify(() => mockDataSource.getComplaints()).called(1);
      });
    });

    group('getComplaintDetails', () {
      test('returns complaint details', () async {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT001',
          type: 'delivery',
          typeLabel: 'Livraison',
          subject: 'Retard',
          description: 'Description...',
          status: 'open',
          statusLabel: 'Ouvert',
          statusColor: '#00FF00',
          priority: 'medium',
          priorityLabel: 'Moyen',
          priorityColor: '#FFA500',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.getComplaintDetails(1))
            .thenAnswer((_) async => complaint);

        final result = await repository.getComplaintDetails(1);

        expect(result, complaint);
        verify(() => mockDataSource.getComplaintDetails(1)).called(1);
      });
    });

    group('getComplaintMessages', () {
      test('returns messages for complaint', () async {
        final messages = [
          ComplaintMessage(
            id: 1,
            message: 'Message',
            isAdmin: false,
            isRead: true,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        when(() => mockDataSource.getComplaintMessages(1))
            .thenAnswer((_) async => messages);

        final result = await repository.getComplaintMessages(1);

        expect(result, messages);
        verify(() => mockDataSource.getComplaintMessages(1)).called(1);
      });
    });

    group('createComplaint', () {
      test('creates complaint with required fields', () async {
        final complaint = Complaint(
          id: 2,
          ticketNumber: 'TKT002',
          type: 'payment',
          typeLabel: 'Paiement',
          subject: 'Problème',
          description: 'Desc...',
          status: 'open',
          statusLabel: 'Ouvert',
          statusColor: '#00FF00',
          priority: 'medium',
          priorityLabel: 'Moyen',
          priorityColor: '#FFA500',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.createComplaint(
              type: 'payment',
              subject: 'Problème',
              description: 'Desc...',
            )).thenAnswer((_) async => complaint);

        final result = await repository.createComplaint(
          type: 'payment',
          subject: 'Problème',
          description: 'Desc...',
        );

        expect(result, complaint);
        verify(() => mockDataSource.createComplaint(
              type: 'payment',
              subject: 'Problème',
              description: 'Desc...',
            )).called(1);
      });

      test('creates complaint with all fields', () async {
        final complaint = Complaint(
          id: 3,
          ticketNumber: 'TKT003',
          type: 'delivery',
          typeLabel: 'Livraison',
          subject: 'Retard',
          description: 'Desc...',
          status: 'open',
          statusLabel: 'Ouvert',
          statusColor: '#00FF00',
          priority: 'high',
          priorityLabel: 'Élevé',
          priorityColor: '#FF0000',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.createComplaint(
              type: 'delivery',
              subject: 'Retard',
              description: 'Desc...',
              orderId: 123,
              priority: 'high',
            )).thenAnswer((_) async => complaint);

        final result = await repository.createComplaint(
          type: 'delivery',
          subject: 'Retard',
          description: 'Desc...',
          orderId: 123,
          priority: 'high',
        );

        expect(result.priority, 'high');
        verify(() => mockDataSource.createComplaint(
              type: 'delivery',
              subject: 'Retard',
              description: 'Desc...',
              orderId: 123,
              priority: 'high',
            )).called(1);
      });
    });

    group('addComplaintMessage', () {
      test('adds message to complaint', () async {
        final message = ComplaintMessage(
          id: 2,
          message: 'Nouveau message',
          isAdmin: false,
          isRead: false,
          createdAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.addComplaintMessage(1, 'Nouveau message'))
            .thenAnswer((_) async => message);

        final result = await repository.addComplaintMessage(1, 'Nouveau message');

        expect(result.message, 'Nouveau message');
        verify(() => mockDataSource.addComplaintMessage(1, 'Nouveau message')).called(1);
      });
    });
  });
}
