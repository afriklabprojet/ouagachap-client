import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/support_chat.dart';

void main() {
  group('SupportChat', () {
    group('Constructor', () {
      test('creates instance with required fields', () {
        final chat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.id, 1);
        expect(chat.status, 'open');
        expect(chat.statusLabel, 'Ouverte');
        expect(chat.createdAt, DateTime(2024, 1, 15));
        expect(chat.subject, isNull);
        expect(chat.lastMessage, isNull);
        expect(chat.unreadCount, 0);
        expect(chat.lastMessageAt, isNull);
      });

      test('creates instance with all fields', () {
        final lastMessage = LastMessage(
          text: 'Hello',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        final chat = SupportChat(
          id: 1,
          subject: 'Test Subject',
          status: 'open',
          statusLabel: 'Ouverte',
          lastMessage: lastMessage,
          unreadCount: 3,
          lastMessageAt: DateTime(2024, 1, 15, 10, 30),
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.subject, 'Test Subject');
        expect(chat.lastMessage, lastMessage);
        expect(chat.unreadCount, 3);
        expect(chat.lastMessageAt, DateTime(2024, 1, 15, 10, 30));
      });
    });

    group('isOpen getter', () {
      test('returns true when status is open', () {
        final chat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.isOpen, isTrue);
      });

      test('returns false when status is not open', () {
        final chat = SupportChat(
          id: 1,
          status: 'closed',
          statusLabel: 'Fermée',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.isOpen, isFalse);
      });
    });

    group('hasUnread getter', () {
      test('returns true when unreadCount > 0', () {
        final chat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 5,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.hasUnread, isTrue);
      });

      test('returns false when unreadCount is 0', () {
        final chat = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 0,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.hasUnread, isFalse);
      });
    });

    group('fromJson', () {
      test('creates instance from complete JSON', () {
        final json = {
          'id': 1,
          'subject': 'Test Subject',
          'status': 'open',
          'status_label': 'Ouverte',
          'last_message': {
            'text': 'Hello',
            'is_admin': true,
            'created_at': '2024-01-15T10:30:00.000Z',
          },
          'unread_count': 3,
          'last_message_at': '2024-01-15T10:30:00.000Z',
          'created_at': '2024-01-15T09:00:00.000Z',
        };

        final chat = SupportChat.fromJson(json);

        expect(chat.id, 1);
        expect(chat.subject, 'Test Subject');
        expect(chat.status, 'open');
        expect(chat.statusLabel, 'Ouverte');
        expect(chat.lastMessage, isNotNull);
        expect(chat.lastMessage!.text, 'Hello');
        expect(chat.unreadCount, 3);
        expect(chat.lastMessageAt, isNotNull);
        expect(chat.createdAt, isNotNull);
      });

      test('handles missing optional fields', () {
        final json = {
          'id': 1,
          'status': 'open',
          'status_label': 'Ouverte',
          'created_at': '2024-01-15T09:00:00.000Z',
        };

        final chat = SupportChat.fromJson(json);

        expect(chat.id, 1);
        expect(chat.subject, isNull);
        expect(chat.lastMessage, isNull);
        expect(chat.unreadCount, 0);
        expect(chat.lastMessageAt, isNull);
      });

      test('handles null fields with defaults', () {
        final json = <String, dynamic>{};

        final chat = SupportChat.fromJson(json);

        expect(chat.id, 0);
        expect(chat.status, 'open');
        expect(chat.statusLabel, 'Ouverte');
        expect(chat.unreadCount, 0);
      });
    });

    group('Equatable', () {
      test('two chats with same props are equal', () {
        final chat1 = SupportChat(
          id: 1,
          subject: 'Test',
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 2,
          lastMessageAt: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15),
        );

        final chat2 = SupportChat(
          id: 1,
          subject: 'Test',
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 2,
          lastMessageAt: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat1, equals(chat2));
        expect(chat1.hashCode, equals(chat2.hashCode));
      });

      test('two chats with different props are not equal', () {
        final chat1 = SupportChat(
          id: 1,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime(2024, 1, 15),
        );

        final chat2 = SupportChat(
          id: 2,
          status: 'open',
          statusLabel: 'Ouverte',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat1, isNot(equals(chat2)));
      });

      test('props contains correct values', () {
        final chat = SupportChat(
          id: 1,
          subject: 'Test',
          status: 'open',
          statusLabel: 'Ouverte',
          unreadCount: 2,
          lastMessageAt: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15),
        );

        expect(chat.props, contains(1)); // id
        expect(chat.props, contains('Test')); // subject
        expect(chat.props, contains('open')); // status
        expect(chat.props, contains(2)); // unreadCount
      });
    });
  });

  group('ChatMessage', () {
    group('Constructor', () {
      test('creates instance with required fields', () {
        final message = ChatMessage(
          id: 1,
          message: 'Hello',
          isAdmin: false,
          isRead: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(message.id, 1);
        expect(message.message, 'Hello');
        expect(message.isAdmin, isFalse);
        expect(message.isRead, isTrue);
        expect(message.senderName, isNull);
        expect(message.createdAt, DateTime(2024, 1, 15));
      });

      test('creates instance with all fields', () {
        final message = ChatMessage(
          id: 1,
          message: 'Hello',
          isAdmin: true,
          isRead: false,
          senderName: 'Support Agent',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(message.senderName, 'Support Agent');
      });
    });

    group('fromJson', () {
      test('creates instance from complete JSON', () {
        final json = {
          'id': 1,
          'message': 'Hello there',
          'is_admin': true,
          'is_read': false,
          'sender_name': 'Agent',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final message = ChatMessage.fromJson(json);

        expect(message.id, 1);
        expect(message.message, 'Hello there');
        expect(message.isAdmin, isTrue);
        expect(message.isRead, isFalse);
        expect(message.senderName, 'Agent');
        expect(message.createdAt, isNotNull);
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final message = ChatMessage.fromJson(json);

        expect(message.id, 0);
        expect(message.message, '');
        expect(message.isAdmin, isFalse);
        expect(message.isRead, isFalse);
        expect(message.senderName, isNull);
      });
    });

    group('Equatable', () {
      test('two messages with same props are equal', () {
        final message1 = ChatMessage(
          id: 1,
          message: 'Hello',
          isAdmin: false,
          isRead: true,
          createdAt: DateTime(2024, 1, 15),
        );

        final message2 = ChatMessage(
          id: 1,
          message: 'Hello',
          isAdmin: false,
          isRead: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(message1, equals(message2));
        expect(message1.hashCode, equals(message2.hashCode));
      });

      test('two messages with different props are not equal', () {
        final message1 = ChatMessage(
          id: 1,
          message: 'Hello',
          isAdmin: false,
          isRead: true,
          createdAt: DateTime(2024, 1, 15),
        );

        final message2 = ChatMessage(
          id: 2,
          message: 'Hello',
          isAdmin: false,
          isRead: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(message1, isNot(equals(message2)));
      });

      test('props contains correct values', () {
        final message = ChatMessage(
          id: 1,
          message: 'Hello',
          isAdmin: true,
          isRead: false,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(message.props, contains(1)); // id
        expect(message.props, contains('Hello')); // message
        expect(message.props, contains(true)); // isAdmin
      });
    });
  });

  group('LastMessage', () {
    group('Constructor', () {
      test('creates instance with required fields', () {
        final lastMessage = LastMessage(
          text: 'Last message text',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(lastMessage.text, 'Last message text');
        expect(lastMessage.isAdmin, isTrue);
        expect(lastMessage.createdAt, DateTime(2024, 1, 15));
      });
    });

    group('fromJson', () {
      test('creates instance from complete JSON', () {
        final json = {
          'text': 'Hello',
          'is_admin': true,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final lastMessage = LastMessage.fromJson(json);

        expect(lastMessage.text, 'Hello');
        expect(lastMessage.isAdmin, isTrue);
        expect(lastMessage.createdAt, isNotNull);
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final lastMessage = LastMessage.fromJson(json);

        expect(lastMessage.text, '');
        expect(lastMessage.isAdmin, isFalse);
      });
    });

    group('Equatable', () {
      test('two lastMessages with same props are equal', () {
        final lastMessage1 = LastMessage(
          text: 'Hello',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15),
        );

        final lastMessage2 = LastMessage(
          text: 'Hello',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(lastMessage1, equals(lastMessage2));
        expect(lastMessage1.hashCode, equals(lastMessage2.hashCode));
      });

      test('two lastMessages with different props are not equal', () {
        final lastMessage1 = LastMessage(
          text: 'Hello',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15),
        );

        final lastMessage2 = LastMessage(
          text: 'Goodbye',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(lastMessage1, isNot(equals(lastMessage2)));
      });

      test('props contains correct values', () {
        final lastMessage = LastMessage(
          text: 'Hello',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(lastMessage.props, contains('Hello')); // text
        expect(lastMessage.props, contains(true)); // isAdmin
      });
    });
  });
}
