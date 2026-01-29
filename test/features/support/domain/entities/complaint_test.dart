import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/complaint.dart';

void main() {
  group('Complaint', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);
    final testComplaint = Complaint(
      id: 1,
      ticketNumber: 'TKT-001',
      type: 'delivery_issue',
      typeLabel: 'Problème de livraison',
      subject: 'Colis endommagé',
      description: 'Mon colis est arrivé abîmé',
      status: 'open',
      statusColor: 'warning',
      statusLabel: 'Ouvert',
      priority: 'high',
      priorityColor: 'danger',
      priorityLabel: 'Haute',
      createdAt: testDate,
      updatedAt: testDate,
    );

    group('constructor', () {
      test('should create Complaint with required fields', () {
        expect(testComplaint.id, 1);
        expect(testComplaint.ticketNumber, 'TKT-001');
        expect(testComplaint.type, 'delivery_issue');
        expect(testComplaint.subject, 'Colis endommagé');
        expect(testComplaint.status, 'open');
      });

      test('should create Complaint with optional fields', () {
        final complaint = Complaint(
          id: 2,
          ticketNumber: 'TKT-002',
          type: 'payment',
          typeLabel: 'Paiement',
          subject: 'Remboursement',
          description: 'Demande de remboursement',
          status: 'resolved',
          statusColor: 'success',
          statusLabel: 'Résolu',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          orderId: 123,
          orderTracking: 'TRK-456',
          resolution: 'Remboursé',
          resolvedAt: testDate,
          unreadCount: 5,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(complaint.orderId, 123);
        expect(complaint.orderTracking, 'TRK-456');
        expect(complaint.resolution, 'Remboursé');
        expect(complaint.resolvedAt, testDate);
        expect(complaint.unreadCount, 5);
      });
    });

    group('status getters', () {
      test('isOpen should return true when status is open', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'warning',
          statusLabel: 'Ouvert',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.isOpen, true);
        expect(complaint.isInProgress, false);
        expect(complaint.isResolved, false);
        expect(complaint.isClosed, false);
      });

      test('isInProgress should return true when status is in_progress', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'in_progress',
          statusColor: 'info',
          statusLabel: 'En cours',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.isInProgress, true);
        expect(complaint.isOpen, false);
      });

      test('isResolved should return true when status is resolved', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'resolved',
          statusColor: 'success',
          statusLabel: 'Résolu',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.isResolved, true);
      });

      test('isClosed should return true when status is closed', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'closed',
          statusColor: 'gray',
          statusLabel: 'Fermé',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.isClosed, true);
      });
    });

    group('canReply', () {
      test('should return true when status is open', () {
        expect(testComplaint.canReply, true);
      });

      test('should return false when status is resolved', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'resolved',
          statusColor: 'success',
          statusLabel: 'Résolu',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.canReply, false);
      });

      test('should return false when status is closed', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'closed',
          statusColor: 'gray',
          statusLabel: 'Fermé',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.canReply, false);
      });
    });

    group('hasUnread', () {
      test('should return true when unreadCount > 0', () {
        final complaint = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'warning',
          statusLabel: 'Ouvert',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          unreadCount: 3,
          createdAt: testDate,
          updatedAt: testDate,
        );
        expect(complaint.hasUnread, true);
      });

      test('should return false when unreadCount is 0', () {
        expect(testComplaint.hasUnread, false);
      });
    });

    group('fromJson', () {
      test('should create Complaint from complete JSON', () {
        final json = {
          'id': 1,
          'ticket_number': 'TKT-123',
          'type': 'delivery_issue',
          'type_label': 'Problème de livraison',
          'subject': 'Retard',
          'description': 'Colis en retard',
          'status': 'open',
          'status_color': 'warning',
          'status_label': 'Ouvert',
          'priority': 'high',
          'priority_color': 'danger',
          'priority_label': 'Haute',
          'order_id': 456,
          'order_tracking': 'TRK-789',
          'resolution': null,
          'resolved_at': null,
          'unread_count': 2,
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
        };

        final complaint = Complaint.fromJson(json);

        expect(complaint.id, 1);
        expect(complaint.ticketNumber, 'TKT-123');
        expect(complaint.type, 'delivery_issue');
        expect(complaint.orderId, 456);
        expect(complaint.unreadCount, 2);
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};
        final complaint = Complaint.fromJson(json);

        expect(complaint.id, 0);
        expect(complaint.ticketNumber, '');
        expect(complaint.type, 'other');
        expect(complaint.status, 'open');
        expect(complaint.priority, 'medium');
      });

      test('should parse lastMessage when present', () {
        final json = {
          'id': 1,
          'ticket_number': 'TKT-001',
          'type': 'other',
          'type_label': 'Autre',
          'subject': 'Test',
          'description': 'Test',
          'status': 'open',
          'status_color': 'warning',
          'status_label': 'Ouvert',
          'priority': 'medium',
          'priority_color': 'info',
          'priority_label': 'Moyenne',
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
          'last_message': {
            'text': 'Dernier message',
            'is_admin': true,
            'created_at': '2024-01-15T11:00:00.000Z',
          },
        };

        final complaint = Complaint.fromJson(json);
        
        expect(complaint.lastMessage, isNotNull);
        expect(complaint.lastMessage!.text, 'Dernier message');
        expect(complaint.lastMessage!.isAdmin, true);
      });

      test('should parse resolvedAt when present', () {
        final json = {
          'id': 1,
          'ticket_number': 'TKT-001',
          'type': 'delivery_issue',
          'type_label': 'Problème de livraison',
          'subject': 'Test',
          'description': 'Test',
          'status': 'resolved',
          'status_color': 'success',
          'status_label': 'Résolu',
          'priority': 'medium',
          'priority_color': 'info',
          'priority_label': 'Moyenne',
          'resolved_at': '2024-01-20T14:00:00.000Z',
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-20T14:00:00.000Z',
        };

        final complaint = Complaint.fromJson(json);
        
        expect(complaint.resolvedAt, isNotNull);
        expect(complaint.resolvedAt!.year, 2024);
        expect(complaint.resolvedAt!.month, 1);
        expect(complaint.resolvedAt!.day, 20);
      });

      test('should use default values for all optional label fields', () {
        final json = {
          'id': 1,
          'ticket_number': 'TKT-001',
          // All label fields missing
        };

        final complaint = Complaint.fromJson(json);
        
        expect(complaint.typeLabel, 'Autre');
        expect(complaint.statusLabel, 'Ouvert');
        expect(complaint.priorityLabel, 'Moyenne');
        expect(complaint.statusColor, 'gray');
        expect(complaint.priorityColor, 'info');
      });
    });

    group('Equatable', () {
      test('props should contain id, ticketNumber, status, unreadCount', () {
        expect(testComplaint.props, [1, 'TKT-001', 'open', 0]);
      });

      test('two complaints with same props should be equal', () {
        final complaint1 = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'other',
          typeLabel: 'Autre',
          subject: 'Test',
          description: 'Test',
          status: 'open',
          statusColor: 'warning',
          statusLabel: 'Ouvert',
          priority: 'medium',
          priorityColor: 'info',
          priorityLabel: 'Moyenne',
          createdAt: testDate,
          updatedAt: testDate,
        );
        final complaint2 = Complaint(
          id: 1,
          ticketNumber: 'TKT-001',
          type: 'different',
          typeLabel: 'Different',
          subject: 'Different',
          description: 'Different',
          status: 'open',
          statusColor: 'different',
          statusLabel: 'Different',
          priority: 'low',
          priorityColor: 'success',
          priorityLabel: 'Basse',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        expect(complaint1, equals(complaint2));
      });
    });
  });

  group('ComplaintMessage', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create ComplaintMessage with required fields', () {
      final message = ComplaintMessage(
        id: 1,
        message: 'Test message',
        isAdmin: false,
        isRead: true,
        createdAt: testDate,
      );

      expect(message.id, 1);
      expect(message.message, 'Test message');
      expect(message.isAdmin, false);
      expect(message.isRead, true);
      expect(message.senderName, isNull);
    });

    test('should create ComplaintMessage with senderName', () {
      final message = ComplaintMessage(
        id: 2,
        message: 'Admin message',
        isAdmin: true,
        isRead: false,
        senderName: 'Support Team',
        createdAt: testDate,
      );

      expect(message.senderName, 'Support Team');
      expect(message.isAdmin, true);
    });

    test('fromJson should create ComplaintMessage from JSON', () {
      final json = {
        'id': 1,
        'message': 'JSON message',
        'is_admin': true,
        'is_read': false,
        'sender_name': 'Admin',
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      final message = ComplaintMessage.fromJson(json);

      expect(message.id, 1);
      expect(message.message, 'JSON message');
      expect(message.isAdmin, true);
      expect(message.senderName, 'Admin');
    });

    test('fromJson should handle missing values', () {
      final json = <String, dynamic>{};
      final message = ComplaintMessage.fromJson(json);

      expect(message.id, 0);
      expect(message.message, '');
      expect(message.isAdmin, false);
      expect(message.isRead, false);
    });

    test('fromJson should parse createdAt when present', () {
      final json = {
        'id': 1,
        'message': 'Test message',
        'is_admin': false,
        'is_read': true,
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      final message = ComplaintMessage.fromJson(json);
      
      expect(message.createdAt.year, 2024);
      expect(message.createdAt.month, 1);
      expect(message.createdAt.day, 15);
    });

    test('props should contain id, message, isAdmin, createdAt', () {
      final message = ComplaintMessage(
        id: 1,
        message: 'Test',
        isAdmin: false,
        isRead: true,
        createdAt: testDate,
      );

      expect(message.props, [1, 'Test', false, testDate]);
    });
  });

  group('LastComplaintMessage', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create LastComplaintMessage', () {
      final lastMessage = LastComplaintMessage(
        text: 'Last message text',
        isAdmin: true,
        createdAt: testDate,
      );

      expect(lastMessage.text, 'Last message text');
      expect(lastMessage.isAdmin, true);
      expect(lastMessage.createdAt, testDate);
    });

    test('fromJson should create from JSON', () {
      final json = {
        'text': 'JSON text',
        'is_admin': false,
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      final lastMessage = LastComplaintMessage.fromJson(json);

      expect(lastMessage.text, 'JSON text');
      expect(lastMessage.isAdmin, false);
    });

    test('fromJson should handle missing values', () {
      final json = <String, dynamic>{};
      final lastMessage = LastComplaintMessage.fromJson(json);

      expect(lastMessage.text, '');
      expect(lastMessage.isAdmin, false);
    });

    test('fromJson should parse createdAt when present', () {
      final json = {
        'text': 'Test',
        'is_admin': true,
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      final lastMessage = LastComplaintMessage.fromJson(json);
      
      expect(lastMessage.createdAt.year, 2024);
      expect(lastMessage.createdAt.month, 1);
      expect(lastMessage.createdAt.day, 15);
    });

    test('props should contain text, isAdmin, createdAt', () {
      final lastMessage = LastComplaintMessage(
        text: 'Test',
        isAdmin: true,
        createdAt: testDate,
      );

      expect(lastMessage.props, ['Test', true, testDate]);
    });
  });

  group('ComplaintType', () {
    test('should create ComplaintType', () {
      const type = ComplaintType(
        value: 'delivery_issue',
        label: 'Problème de livraison',
        icon: 'truck',
      );

      expect(type.value, 'delivery_issue');
      expect(type.label, 'Problème de livraison');
      expect(type.icon, 'truck');
    });

    test('fromJson should create from JSON', () {
      final json = {
        'value': 'payment',
        'label': 'Paiement',
        'icon': 'credit-card',
      };

      final type = ComplaintType.fromJson(json);

      expect(type.value, 'payment');
      expect(type.label, 'Paiement');
      expect(type.icon, 'credit-card');
    });

    test('fromJson should use default icon', () {
      final json = {
        'value': 'other',
        'label': 'Autre',
      };

      final type = ComplaintType.fromJson(json);

      expect(type.icon, 'help-circle');
    });

    test('props should contain value, label, icon', () {
      const type = ComplaintType(
        value: 'test',
        label: 'Test',
        icon: 'test-icon',
      );

      expect(type.props, ['test', 'Test', 'test-icon']);
    });
  });
}
