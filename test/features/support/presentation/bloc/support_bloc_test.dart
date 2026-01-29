import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/support/presentation/bloc/support_bloc.dart';
import 'package:ouaga_chap_client/features/support/presentation/bloc/support_event.dart';
import 'package:ouaga_chap_client/features/support/presentation/bloc/support_state.dart';
import 'package:ouaga_chap_client/features/support/data/repositories/support_repository.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/contact_info.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/faq.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/support_chat.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/complaint.dart';

class MockSupportRepository extends Mock implements SupportRepository {}

void main() {
  late SupportBloc bloc;
  late MockSupportRepository mockRepository;

  setUp(() {
    mockRepository = MockSupportRepository();
    bloc = SupportBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final testContactInfo = ContactInfo(
    phone: '+22670000000',
    phoneDisplay: '70 00 00 00',
    email: 'support@ouagachap.com',
    whatsapp: '+22670000000',
    whatsappMessage: 'Bonjour',
    workingHours: const WorkingHours(days: 'Lun-Sam', hours: '8h-18h'),
    social: const SocialLinks(
      facebook: 'https://facebook.com/ouagachap',
      instagram: 'https://instagram.com/ouagachap',
      twitter: 'https://twitter.com/ouagachap',
    ),
    address: const Address(street: 'Rue 1', city: 'Ouagadougou', country: 'Burkina Faso'),
  );

  final testFaqs = [
    const Faq(
      id: 1,
      category: 'general',
      categoryLabel: 'Général',
      categoryIcon: 'help',
      question: 'Comment créer un compte?',
      answer: 'Téléchargez l\'app...',
    ),
    const Faq(
      id: 2,
      category: 'payment',
      categoryLabel: 'Paiement',
      categoryIcon: 'payment',
      question: 'Quels modes de paiement?',
      answer: 'Orange Money, Moov...',
    ),
  ];

  final testChat = SupportChat(
    id: 1,
    subject: 'Question sur livraison',
    status: 'open',
    statusLabel: 'Ouvert',
    unreadCount: 0,
    lastMessage: LastMessage(
      text: 'Bonjour',
      createdAt: DateTime(2024, 1, 15),
      isAdmin: false,
    ),
    createdAt: DateTime(2024, 1, 15),
  );

  final testChatMessage = ChatMessage(
    id: 1,
    message: 'Bonjour, j\'ai une question',
    isAdmin: false,
    isRead: false,
    senderName: null,
    createdAt: DateTime(2024, 1, 15),
  );

  final testComplaint = Complaint(
    id: 1,
    ticketNumber: 'TICKET-001',
    type: 'delivery',
    typeLabel: 'Livraison',
    subject: 'Colis endommagé',
    description: 'Mon colis est arrivé abîmé',
    status: 'open',
    statusColor: 'orange',
    statusLabel: 'Ouvert',
    priority: 'medium',
    priorityColor: 'yellow',
    priorityLabel: 'Moyenne',
    unreadCount: 0,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  final testComplaintMessage = ComplaintMessage(
    id: 1,
    message: 'Description du problème',
    isAdmin: false,
    isRead: false,
    senderName: null,
    createdAt: DateTime(2024, 1, 15),
  );

  group('SupportBloc', () {
    test('initial state is correct', () {
      expect(bloc.state.status, SupportStatus.initial);
      expect(bloc.state.faqs, isEmpty);
      expect(bloc.state.chats, isEmpty);
      expect(bloc.state.complaints, isEmpty);
    });

    group('LoadContactInfo', () {
      test('emits success when getContactInfo succeeds', () async {
        // Arrange
        when(() => mockRepository.getContactInfo())
            .thenAnswer((_) async => testContactInfo);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.status == SupportStatus.loading),
            predicate<SupportState>((s) => 
                s.status == SupportStatus.success && 
                s.contactInfo?.phone == '+22670000000'),
          ]),
        );

        // Act
        bloc.add(LoadContactInfo());
      });

      test('emits failure when getContactInfo fails', () async {
        // Arrange
        when(() => mockRepository.getContactInfo())
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.status == SupportStatus.loading),
            predicate<SupportState>((s) => 
                s.status == SupportStatus.failure && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(LoadContactInfo());
      });
    });

    group('LoadFaqs', () {
      test('emits success when getFaqs succeeds', () async {
        // Arrange
        when(() => mockRepository.getFaqs(
          category: any(named: 'category'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => testFaqs);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.faqsLoading == true),
            predicate<SupportState>((s) => 
                s.faqsLoading == false && 
                s.faqs.length == 2),
          ]),
        );

        // Act
        bloc.add(const LoadFaqs());
      });

      test('emits failure when getFaqs fails', () async {
        // Arrange
        when(() => mockRepository.getFaqs(
          category: any(named: 'category'),
          search: any(named: 'search'),
        )).thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.faqsLoading == true),
            predicate<SupportState>((s) => 
                s.faqsLoading == false && 
                s.status == SupportStatus.failure),
          ]),
        );

        // Act
        bloc.add(const LoadFaqs());
      });

      test('loads FAQs with specific category', () async {
        // Arrange
        when(() => mockRepository.getFaqs(
          category: 'payment',
          search: any(named: 'search'),
        )).thenAnswer((_) async => [testFaqs[1]]);

        bloc.add(const LoadFaqs(category: 'payment'));
        await Future.delayed(const Duration(milliseconds: 150));

        // Verify call
        verify(() => mockRepository.getFaqs(
          category: 'payment',
          search: '',
        )).called(1);
      });
    });

    group('ViewFaq', () {
      test('calls repository viewFaq', () async {
        // Arrange
        when(() => mockRepository.viewFaq(any()))
            .thenAnswer((_) async {});

        // Act
        bloc.add(const ViewFaq(1));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        verify(() => mockRepository.viewFaq(1)).called(1);
      });

      test('handles viewFaq error silently', () async {
        // Arrange
        when(() => mockRepository.viewFaq(any()))
            .thenThrow(Exception('Error'));

        // Act
        bloc.add(const ViewFaq(1));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - no error state should be emitted
        expect(bloc.state.status, SupportStatus.initial);
      });
    });

    group('ChangeFaqCategory', () {
      test('updates category and triggers LoadFaqs', () async {
        // Arrange
        when(() => mockRepository.getFaqs(
          category: any(named: 'category'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => testFaqs);

        // Act
        bloc.add(const ChangeFaqCategory('payment'));
        await Future.delayed(const Duration(milliseconds: 150));

        // Assert
        expect(bloc.state.selectedFaqCategory, 'payment');
        verify(() => mockRepository.getFaqs(
          category: 'payment',
          search: '',
        )).called(1);
      });
    });

    group('SearchFaqs', () {
      test('updates search query and triggers LoadFaqs', () async {
        // Arrange
        when(() => mockRepository.getFaqs(
          category: any(named: 'category'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => testFaqs);

        // Act
        bloc.add(const SearchFaqs('paiement'));
        await Future.delayed(const Duration(milliseconds: 150));

        // Assert
        expect(bloc.state.faqSearchQuery, 'paiement');
        verify(() => mockRepository.getFaqs(
          category: 'all',
          search: 'paiement',
        )).called(1);
      });
    });

    group('LoadChats', () {
      test('emits success when getChats succeeds', () async {
        // Arrange
        when(() => mockRepository.getChats())
            .thenAnswer((_) async => [testChat]);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.chatLoading == true),
            predicate<SupportState>((s) => 
                s.chatLoading == false && 
                s.chats.length == 1),
          ]),
        );

        // Act
        bloc.add(LoadChats());
      });

      test('emits failure when getChats fails', () async {
        // Arrange
        when(() => mockRepository.getChats())
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.chatLoading == true),
            predicate<SupportState>((s) => 
                s.chatLoading == false && 
                s.status == SupportStatus.failure),
          ]),
        );

        // Act
        bloc.add(LoadChats());
      });
    });

    group('OpenChat', () {
      test('emits success when getOrCreateChat succeeds', () async {
        // Arrange
        when(() => mockRepository.getOrCreateChat(subject: any(named: 'subject')))
            .thenAnswer((_) async => testChat);
        when(() => mockRepository.getChatMessages(any()))
            .thenAnswer((_) async => [testChatMessage]);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.chatLoading == true),
            predicate<SupportState>((s) => 
                s.chatLoading == false && 
                s.currentChat != null &&
                s.chatMessages.length == 1),
          ]),
        );

        // Act
        bloc.add(const OpenChat(subject: 'Question'));
      });
    });

    group('SendChatMessage', () {
      test('emits success when sendChatMessage succeeds', () async {
        // First open a chat
        when(() => mockRepository.getOrCreateChat(subject: any(named: 'subject')))
            .thenAnswer((_) async => testChat);
        when(() => mockRepository.getChatMessages(any()))
            .thenAnswer((_) async => []);
        when(() => mockRepository.sendChatMessage(any(), any()))
            .thenAnswer((_) async => testChatMessage);

        bloc.add(const OpenChat());
        await Future.delayed(const Duration(milliseconds: 150));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.sendingMessage == true),
            predicate<SupportState>((s) => 
                s.sendingMessage == false && 
                s.chatMessages.length == 1),
          ]),
        );

        // Act
        bloc.add(const SendChatMessage(1, 'Hello'));
      });
    });

    group('LoadComplaints', () {
      test('emits success when getComplaints succeeds', () async {
        // Arrange
        when(() => mockRepository.getComplaints())
            .thenAnswer((_) async => [testComplaint]);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.complaintsLoading == true),
            predicate<SupportState>((s) => 
                s.complaintsLoading == false && 
                s.complaints.length == 1),
          ]),
        );

        // Act
        bloc.add(LoadComplaints());
      });

      test('emits failure when getComplaints fails', () async {
        // Arrange
        when(() => mockRepository.getComplaints())
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.complaintsLoading == true),
            predicate<SupportState>((s) => 
                s.complaintsLoading == false && 
                s.status == SupportStatus.failure),
          ]),
        );

        // Act
        bloc.add(LoadComplaints());
      });
    });

    group('CreateComplaint', () {
      test('emits success when createComplaint succeeds', () async {
        // Arrange
        when(() => mockRepository.createComplaint(
          type: any(named: 'type'),
          subject: any(named: 'subject'),
          description: any(named: 'description'),
          orderId: any(named: 'orderId'),
          priority: any(named: 'priority'),
        )).thenAnswer((_) async => testComplaint);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.creatingComplaint == true),
            predicate<SupportState>((s) => 
                s.creatingComplaint == false && 
                s.currentComplaint != null &&
                s.complaints.isNotEmpty),
          ]),
        );

        // Act
        bloc.add(const CreateComplaint(
          type: 'delivery',
          subject: 'Colis abîmé',
          description: 'Mon colis...',
        ));
      });

      test('emits failure when createComplaint fails', () async {
        // Arrange
        when(() => mockRepository.createComplaint(
          type: any(named: 'type'),
          subject: any(named: 'subject'),
          description: any(named: 'description'),
          orderId: any(named: 'orderId'),
          priority: any(named: 'priority'),
        )).thenThrow(Exception('Server error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.creatingComplaint == true),
            predicate<SupportState>((s) => 
                s.creatingComplaint == false && 
                s.status == SupportStatus.failure),
          ]),
        );

        // Act
        bloc.add(const CreateComplaint(
          type: 'delivery',
          subject: 'Colis abîmé',
          description: 'Mon colis...',
        ));
      });
    });

    group('AddComplaintMessage', () {
      test('emits success when addComplaintMessage succeeds', () async {
        // Arrange
        when(() => mockRepository.addComplaintMessage(any(), any()))
            .thenAnswer((_) async => testComplaintMessage);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.sendingMessage == true),
            predicate<SupportState>((s) => 
                s.sendingMessage == false && 
                s.complaintMessages.length == 1),
          ]),
        );

        // Act
        bloc.add(const AddComplaintMessage(1, 'Réponse'));
      });

      test('emits error when addComplaintMessage fails', () async {
        // Arrange
        when(() => mockRepository.addComplaintMessage(any(), any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.sendingMessage == true),
            predicate<SupportState>((s) => 
                s.sendingMessage == false && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(const AddComplaintMessage(1, 'Réponse'));
      });
    });

    group('LoadChatMessages', () {
      test('emits success when getChatMessages succeeds', () async {
        // Arrange
        when(() => mockRepository.getChatMessages(any()))
            .thenAnswer((_) async => [testChatMessage]);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.chatLoading == true),
            predicate<SupportState>((s) => 
                s.chatLoading == false && 
                s.chatMessages.length == 1),
          ]),
        );

        // Act
        bloc.add(const LoadChatMessages(1));
      });

      test('emits error when getChatMessages fails', () async {
        // Arrange
        when(() => mockRepository.getChatMessages(any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.chatLoading == true),
            predicate<SupportState>((s) => 
                s.chatLoading == false && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(const LoadChatMessages(1));
      });
    });

    group('SendChatMessage', () {
      test('emits error when sendChatMessage fails', () async {
        // Arrange
        when(() => mockRepository.sendChatMessage(any(), any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.sendingMessage == true),
            predicate<SupportState>((s) => 
                s.sendingMessage == false && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(const SendChatMessage(1, 'Test message'));
      });
    });

    group('OpenChat', () {
      test('emits error when getOrCreateChat fails', () async {
        // Arrange
        when(() => mockRepository.getOrCreateChat(subject: any(named: 'subject')))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.chatLoading == true),
            predicate<SupportState>((s) => 
                s.chatLoading == false && 
                s.status == SupportStatus.failure),
          ]),
        );

        // Act
        bloc.add(const OpenChat(subject: 'Test'));
      });
    });

    group('CloseChat', () {
      test('calls repository and loads chats on success', () async {
        // Arrange
        when(() => mockRepository.closeChat(any()))
            .thenAnswer((_) async => testChat);
        when(() => mockRepository.getChats())
            .thenAnswer((_) async => []);

        // Act
        bloc.add(const CloseChat(1));
        await Future.delayed(const Duration(milliseconds: 150));

        // Assert
        verify(() => mockRepository.closeChat(1)).called(1);
      });

      test('emits error when closeChat fails', () async {
        // Arrange
        when(() => mockRepository.closeChat(any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emits(predicate<SupportState>((s) => s.errorMessage != null)),
        );

        // Act
        bloc.add(const CloseChat(1));
      });
    });

    group('LoadComplaintDetails', () {
      test('emits success when getComplaintDetails succeeds', () async {
        // Arrange
        when(() => mockRepository.getComplaintDetails(any()))
            .thenAnswer((_) async => testComplaint);
        when(() => mockRepository.getComplaintMessages(any()))
            .thenAnswer((_) async => [testComplaintMessage]);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.complaintsLoading == true),
            predicate<SupportState>((s) => 
                s.complaintsLoading == false && 
                s.currentComplaint != null &&
                s.complaintMessages.length == 1),
          ]),
        );

        // Act
        bloc.add(const LoadComplaintDetails(1));
      });

      test('emits error when getComplaintDetails fails', () async {
        // Arrange
        when(() => mockRepository.getComplaintDetails(any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SupportState>((s) => s.complaintsLoading == true),
            predicate<SupportState>((s) => 
                s.complaintsLoading == false && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(const LoadComplaintDetails(1));
      });
    });

    group('ResetSupportState', () {
      test('resets state to initial', () async {
        // First load some data
        when(() => mockRepository.getComplaints())
            .thenAnswer((_) async => [testComplaint]);
        
        bloc.add(LoadComplaints());
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state.complaints.isNotEmpty, true);

        // Reset
        expectLater(
          bloc.stream,
          emits(predicate<SupportState>((s) => 
              s.status == SupportStatus.initial &&
              s.complaints.isEmpty)),
        );

        bloc.add(ResetSupportState());
      });
    });

    group('ClearSupportError', () {
      test('clears error message', () async {
        // First create an error state
        when(() => mockRepository.getComplaints())
            .thenThrow(Exception('Error'));
        
        bloc.add(LoadComplaints());
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state.errorMessage, isNotNull);

        // Clear error
        expectLater(
          bloc.stream,
          emits(predicate<SupportState>((s) => s.errorMessage == null)),
        );

        bloc.add(ClearSupportError());
      });
    });
  });
}
