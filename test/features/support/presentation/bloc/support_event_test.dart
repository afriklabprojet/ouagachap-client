import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/support/presentation/bloc/support_event.dart';

void main() {
  group('SupportEvent', () {
    group('LoadContactInfo', () {
      test('creates instance', () {
        final event = LoadContactInfo();
        expect(event, isA<SupportEvent>());
      });

      test('props is empty', () {
        final event = LoadContactInfo();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        final event1 = LoadContactInfo();
        final event2 = LoadContactInfo();
        expect(event1, equals(event2));
      });
    });

    group('LoadFaqs', () {
      test('creates instance without parameters', () {
        const event = LoadFaqs();
        expect(event.category, isNull);
        expect(event.search, isNull);
      });

      test('creates instance with category', () {
        const event = LoadFaqs(category: 'orders');
        expect(event.category, 'orders');
      });

      test('creates instance with search', () {
        const event = LoadFaqs(search: 'payment');
        expect(event.search, 'payment');
      });

      test('creates instance with both parameters', () {
        const event = LoadFaqs(category: 'orders', search: 'payment');
        expect(event.category, 'orders');
        expect(event.search, 'payment');
      });

      test('props contains category and search', () {
        const event = LoadFaqs(category: 'orders', search: 'payment');
        expect(event.props, ['orders', 'payment']);
      });

      test('two events with same props are equal', () {
        const event1 = LoadFaqs(category: 'orders');
        const event2 = LoadFaqs(category: 'orders');
        expect(event1, equals(event2));
      });
    });

    group('ViewFaq', () {
      test('creates instance with faqId', () {
        const event = ViewFaq(123);
        expect(event.faqId, 123);
      });

      test('props contains faqId', () {
        const event = ViewFaq(456);
        expect(event.props, [456]);
      });

      test('two events with same faqId are equal', () {
        const event1 = ViewFaq(1);
        const event2 = ViewFaq(1);
        expect(event1, equals(event2));
      });

      test('two events with different faqId are not equal', () {
        const event1 = ViewFaq(1);
        const event2 = ViewFaq(2);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('ChangeFaqCategory', () {
      test('creates instance with category', () {
        const event = ChangeFaqCategory('payments');
        expect(event.category, 'payments');
      });

      test('props contains category', () {
        const event = ChangeFaqCategory('orders');
        expect(event.props, ['orders']);
      });

      test('two events with same category are equal', () {
        const event1 = ChangeFaqCategory('orders');
        const event2 = ChangeFaqCategory('orders');
        expect(event1, equals(event2));
      });
    });

    group('SearchFaqs', () {
      test('creates instance with query', () {
        const event = SearchFaqs('how to pay');
        expect(event.query, 'how to pay');
      });

      test('props contains query', () {
        const event = SearchFaqs('payment');
        expect(event.props, ['payment']);
      });

      test('two events with same query are equal', () {
        const event1 = SearchFaqs('test');
        const event2 = SearchFaqs('test');
        expect(event1, equals(event2));
      });
    });

    group('LoadChats', () {
      test('creates instance', () {
        final event = LoadChats();
        expect(event, isA<SupportEvent>());
      });

      test('props is empty', () {
        final event = LoadChats();
        expect(event.props, isEmpty);
      });
    });

    group('OpenChat', () {
      test('creates instance without subject', () {
        const event = OpenChat();
        expect(event.subject, isNull);
      });

      test('creates instance with subject', () {
        const event = OpenChat(subject: 'Order issue');
        expect(event.subject, 'Order issue');
      });

      test('props contains subject', () {
        const event = OpenChat(subject: 'Test');
        expect(event.props, ['Test']);
      });
    });

    group('LoadChatMessages', () {
      test('creates instance with chatId', () {
        const event = LoadChatMessages(123);
        expect(event.chatId, 123);
      });

      test('props contains chatId', () {
        const event = LoadChatMessages(456);
        expect(event.props, [456]);
      });
    });

    group('SendChatMessage', () {
      test('creates instance with chatId and message', () {
        const event = SendChatMessage(1, 'Hello');
        expect(event.chatId, 1);
        expect(event.message, 'Hello');
      });

      test('props contains chatId and message', () {
        const event = SendChatMessage(1, 'Hello');
        expect(event.props, [1, 'Hello']);
      });

      test('two events with same props are equal', () {
        const event1 = SendChatMessage(1, 'Hello');
        const event2 = SendChatMessage(1, 'Hello');
        expect(event1, equals(event2));
      });
    });

    group('CloseChat', () {
      test('creates instance with chatId', () {
        const event = CloseChat(123);
        expect(event.chatId, 123);
      });

      test('props contains chatId', () {
        const event = CloseChat(456);
        expect(event.props, [456]);
      });
    });

    group('LoadComplaints', () {
      test('creates instance', () {
        final event = LoadComplaints();
        expect(event, isA<SupportEvent>());
      });

      test('props is empty', () {
        final event = LoadComplaints();
        expect(event.props, isEmpty);
      });
    });

    group('LoadComplaintDetails', () {
      test('creates instance with complaintId', () {
        const event = LoadComplaintDetails(123);
        expect(event.complaintId, 123);
      });

      test('props contains complaintId', () {
        const event = LoadComplaintDetails(456);
        expect(event.props, [456]);
      });
    });

    group('CreateComplaint', () {
      test('creates instance with required fields', () {
        const event = CreateComplaint(
          type: 'order',
          subject: 'Late delivery',
          description: 'My order is late',
        );

        expect(event.type, 'order');
        expect(event.subject, 'Late delivery');
        expect(event.description, 'My order is late');
        expect(event.orderId, isNull);
        expect(event.priority, isNull);
      });

      test('creates instance with all fields', () {
        const event = CreateComplaint(
          type: 'order',
          subject: 'Late delivery',
          description: 'My order is late',
          orderId: 123,
          priority: 'high',
        );

        expect(event.orderId, 123);
        expect(event.priority, 'high');
      });

      test('props contains all fields', () {
        const event = CreateComplaint(
          type: 'order',
          subject: 'Subject',
          description: 'Desc',
          orderId: 1,
          priority: 'low',
        );
        expect(event.props, ['order', 'Subject', 'Desc', 1, 'low']);
      });

      test('two events with same props are equal', () {
        const event1 = CreateComplaint(
          type: 'order',
          subject: 'Test',
          description: 'Test desc',
        );
        const event2 = CreateComplaint(
          type: 'order',
          subject: 'Test',
          description: 'Test desc',
        );
        expect(event1, equals(event2));
      });
    });

    group('AddComplaintMessage', () {
      test('creates instance with complaintId and message', () {
        const event = AddComplaintMessage(1, 'New message');
        expect(event.complaintId, 1);
        expect(event.message, 'New message');
      });

      test('props contains complaintId and message', () {
        const event = AddComplaintMessage(1, 'Hello');
        expect(event.props, [1, 'Hello']);
      });
    });

    group('ResetSupportState', () {
      test('creates instance', () {
        final event = ResetSupportState();
        expect(event, isA<SupportEvent>());
      });

      test('props is empty', () {
        final event = ResetSupportState();
        expect(event.props, isEmpty);
      });
    });

    group('ClearSupportError', () {
      test('creates instance', () {
        final event = ClearSupportError();
        expect(event, isA<SupportEvent>());
      });

      test('props is empty', () {
        final event = ClearSupportError();
        expect(event.props, isEmpty);
      });
    });
  });
}
