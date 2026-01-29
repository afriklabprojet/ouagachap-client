import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/support/data/datasources/support_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late SupportRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = SupportRemoteDataSourceImpl(mockApiClient);
  });

  group('SupportRemoteDataSourceImpl', () {
    // ==================== CONTACT INFO ====================
    group('getContactInfo', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/contact'),
        data: {
          'data': {
            'phone': '70000000',
            'email': 'support@example.com',
            'address': {
              'street': '123 Main St',
              'city': 'Ouagadougou',
              'country': 'Burkina Faso',
            },
            'working_hours': {
              'days': 'Lun-Ven',
              'hours': '8h-18h',
            },
          },
        },
      );

      test('should return contact info from API', () async {
        // Arrange
        when(() => mockApiClient.get('support/contact'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getContactInfo();

        // Assert
        expect(result.phone, equals('70000000'));
        expect(result.email, equals('support@example.com'));
        verify(() => mockApiClient.get('support/contact')).called(1);
      });
    });

    // ==================== FAQs ====================
    group('getFaqs', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/faqs'),
        data: {
          'data': {
            'faqs': [
              {
                'id': 1,
                'question': 'FAQ 1?',
                'answer': 'Answer 1',
                'category': 'general',
              },
            ],
          },
        },
      );

      test('should return FAQs from API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'support/faqs',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getFaqs();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].question, equals('FAQ 1?'));
        verify(() => mockApiClient.get(
              'support/faqs',
              queryParameters: {},
            )).called(1);
      });

      test('should pass category filter to API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'support/faqs',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getFaqs(category: 'payment');

        // Assert
        verify(() => mockApiClient.get(
              'support/faqs',
              queryParameters: {'category': 'payment'},
            )).called(1);
      });

      test('should pass search filter to API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'support/faqs',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getFaqs(search: 'test');

        // Assert
        verify(() => mockApiClient.get(
              'support/faqs',
              queryParameters: {'search': 'test'},
            )).called(1);
      });

      test('should not pass "all" category to API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'support/faqs',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getFaqs(category: 'all');

        // Assert
        verify(() => mockApiClient.get(
              'support/faqs',
              queryParameters: {},
            )).called(1);
      });

      test('should not pass empty search to API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'support/faqs',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getFaqs(search: '');

        // Assert
        verify(() => mockApiClient.get(
              'support/faqs',
              queryParameters: {},
            )).called(1);
      });
    });

    group('viewFaq', () {
      test('should call view FAQ API', () async {
        // Arrange
        final testResponse = Response(
          requestOptions: RequestOptions(path: 'support/faqs/1/view'),
          data: {'success': true},
        );
        when(() => mockApiClient.post('support/faqs/1/view'))
            .thenAnswer((_) async => testResponse);

        // Act
        await dataSource.viewFaq(1);

        // Assert
        verify(() => mockApiClient.post('support/faqs/1/view')).called(1);
      });
    });

    // ==================== CHAT SUPPORT ====================
    group('getChats', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/chats'),
        data: {
          'data': {
            'chats': [
              {
                'id': 1,
                'subject': 'Test Chat',
                'status': 'open',
                'status_label': 'Ouvert',
                'last_message': {
                  'message': 'Hello',
                  'is_admin': false,
                  'created_at': '2024-01-15T10:00:00Z',
                },
                'unread_count': 2,
                'last_message_at': '2024-01-15T10:00:00Z',
                'created_at': '2024-01-15T09:00:00Z',
              },
            ],
          },
        },
      );

      test('should return chats from API', () async {
        // Arrange
        when(() => mockApiClient.get('support/chats'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getChats();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].subject, equals('Test Chat'));
        verify(() => mockApiClient.get('support/chats')).called(1);
      });
    });

    group('getOrCreateChat', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/chats'),
        data: {
          'data': {
            'id': 1,
            'subject': 'New Chat',
            'status': 'open',
            'status_label': 'Ouvert',
            'last_message': null,
            'unread_count': 0,
            'last_message_at': null,
            'created_at': '2024-01-15T10:00:00Z',
          },
        },
      );

      test('should create chat without subject', () async {
        // Arrange
        when(() => mockApiClient.post(
              'support/chats',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getOrCreateChat();

        // Assert
        expect(result.id, equals(1));
        verify(() => mockApiClient.post(
              'support/chats',
              data: null,
            )).called(1);
      });

      test('should create chat with subject', () async {
        // Arrange
        when(() => mockApiClient.post(
              'support/chats',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getOrCreateChat(subject: 'Test Subject');

        // Assert
        verify(() => mockApiClient.post(
              'support/chats',
              data: {'subject': 'Test Subject'},
            )).called(1);
      });
    });

    group('getChatMessages', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/chats/1/messages'),
        data: {
          'data': {
            'messages': [
              {
                'id': 1,
                'message': 'Hello',
                'is_admin': false,
                'is_read': true,
                'sender_name': 'User',
                'created_at': '2024-01-15T10:00:00Z',
              },
            ],
          },
        },
      );

      test('should return chat messages from API', () async {
        // Arrange
        when(() => mockApiClient.get('support/chats/1/messages'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getChatMessages(1);

        // Assert
        expect(result.length, equals(1));
        expect(result[0].message, equals('Hello'));
        verify(() => mockApiClient.get('support/chats/1/messages')).called(1);
      });
    });

    group('sendChatMessage', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/chats/1/messages'),
        data: {
          'data': {
            'id': 2,
            'message': 'New message',
            'is_admin': false,
            'is_read': false,
            'sender_name': 'User',
            'created_at': '2024-01-15T11:00:00Z',
          },
        },
      );

      test('should send message and return response', () async {
        // Arrange
        when(() => mockApiClient.post(
              'support/chats/1/messages',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.sendChatMessage(1, 'New message');

        // Assert
        expect(result.message, equals('New message'));
        verify(() => mockApiClient.post(
              'support/chats/1/messages',
              data: {'message': 'New message'},
            )).called(1);
      });
    });

    group('closeChat', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/chats/1/close'),
        data: {
          'data': {
            'id': 1,
            'subject': 'Closed Chat',
            'status': 'closed',
            'status_label': 'Fermé',
            'last_message': {
              'message': 'Goodbye',
              'is_admin': false,
              'created_at': '2024-01-15T12:00:00Z',
            },
            'unread_count': 0,
            'last_message_at': '2024-01-15T12:00:00Z',
            'created_at': '2024-01-15T09:00:00Z',
          },
        },
      );

      test('should close chat and return updated chat', () async {
        // Arrange
        when(() => mockApiClient.post('support/chats/1/close'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.closeChat(1);

        // Assert
        expect(result.status, equals('closed'));
        verify(() => mockApiClient.post('support/chats/1/close')).called(1);
      });
    });

    // ==================== COMPLAINTS ====================
    group('getComplaints', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/complaints'),
        data: {
          'data': {
            'complaints': [
              {
                'id': 1,
                'type': 'order',
                'type_label': 'Commande',
                'subject': 'Test Complaint',
                'description': 'Test description',
                'status': 'open',
                'status_label': 'Ouvert',
                'priority': 'normal',
                'priority_label': 'Normal',
                'created_at': '2024-01-15T10:00:00Z',
                'updated_at': '2024-01-15T10:00:00Z',
              },
            ],
          },
        },
      );

      test('should return complaints from API', () async {
        // Arrange
        when(() => mockApiClient.get('support/complaints'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getComplaints();

        // Assert
        expect(result.length, equals(1));
        expect(result[0].subject, equals('Test Complaint'));
        verify(() => mockApiClient.get('support/complaints')).called(1);
      });
    });

    group('getComplaintDetails', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/complaints/1'),
        data: {
          'data': {
            'complaint': {
              'id': 1,
              'type': 'order',
              'type_label': 'Commande',
              'subject': 'Complaint Details',
              'description': 'Detailed description',
              'status': 'open',
              'status_label': 'Ouvert',
              'priority': 'high',
              'priority_label': 'Élevé',
              'created_at': '2024-01-15T10:00:00Z',
              'updated_at': '2024-01-15T10:00:00Z',
            },
          },
        },
      );

      test('should return complaint details from API', () async {
        // Arrange
        when(() => mockApiClient.get('support/complaints/1'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getComplaintDetails(1);

        // Assert
        expect(result.subject, equals('Complaint Details'));
        verify(() => mockApiClient.get('support/complaints/1')).called(1);
      });
    });

    group('getComplaintMessages', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/complaints/1'),
        data: {
          'data': {
            'messages': [
              {
                'id': 1,
                'message': 'Complaint message',
                'is_admin': false,
                'created_at': '2024-01-15T10:00:00Z',
              },
            ],
          },
        },
      );

      test('should return complaint messages from API', () async {
        // Arrange
        when(() => mockApiClient.get('support/complaints/1'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getComplaintMessages(1);

        // Assert
        expect(result.length, equals(1));
        expect(result[0].message, equals('Complaint message'));
        verify(() => mockApiClient.get('support/complaints/1')).called(1);
      });
    });

    group('createComplaint', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/complaints'),
        data: {
          'data': {
            'id': 2,
            'type': 'order',
            'type_label': 'Commande',
            'subject': 'New Complaint',
            'description': 'New description',
            'status': 'open',
            'status_label': 'Ouvert',
            'priority': 'normal',
            'priority_label': 'Normal',
            'created_at': '2024-01-15T10:00:00Z',
            'updated_at': '2024-01-15T10:00:00Z',
          },
        },
      );

      test('should create complaint with required fields', () async {
        // Arrange
        when(() => mockApiClient.post(
              'support/complaints',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.createComplaint(
          type: 'order',
          subject: 'New Complaint',
          description: 'New description',
        );

        // Assert
        expect(result.subject, equals('New Complaint'));
        verify(() => mockApiClient.post(
              'support/complaints',
              data: {
                'type': 'order',
                'subject': 'New Complaint',
                'description': 'New description',
              },
            )).called(1);
      });

      test('should create complaint with optional fields', () async {
        // Arrange
        when(() => mockApiClient.post(
              'support/complaints',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.createComplaint(
          type: 'order',
          subject: 'New Complaint',
          description: 'New description',
          orderId: 123,
          priority: 'high',
        );

        // Assert
        verify(() => mockApiClient.post(
              'support/complaints',
              data: {
                'type': 'order',
                'subject': 'New Complaint',
                'description': 'New description',
                'order_id': 123,
                'priority': 'high',
              },
            )).called(1);
      });
    });

    group('addComplaintMessage', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'support/complaints/1/messages'),
        data: {
          'data': {
            'id': 2,
            'message': 'New complaint message',
            'is_admin': false,
            'created_at': '2024-01-15T11:00:00Z',
          },
        },
      );

      test('should add message to complaint', () async {
        // Arrange
        when(() => mockApiClient.post(
              'support/complaints/1/messages',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.addComplaintMessage(1, 'New complaint message');

        // Assert
        expect(result.message, equals('New complaint message'));
        verify(() => mockApiClient.post(
              'support/complaints/1/messages',
              data: {'message': 'New complaint message'},
            )).called(1);
      });
    });
  });
}
