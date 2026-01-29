import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact_info.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/support_chat.dart';
import '../../domain/entities/complaint.dart';

abstract class SupportRemoteDataSource {
  // Contact Info
  Future<ContactInfo> getContactInfo();

  // FAQs
  Future<List<Faq>> getFaqs({String? category, String? search});
  Future<void> viewFaq(int faqId);

  // Chat Support
  Future<List<SupportChat>> getChats();
  Future<SupportChat> getOrCreateChat({String? subject});
  Future<List<ChatMessage>> getChatMessages(int chatId);
  Future<ChatMessage> sendChatMessage(int chatId, String message);
  Future<SupportChat> closeChat(int chatId);

  // Complaints
  Future<List<Complaint>> getComplaints();
  Future<Complaint> getComplaintDetails(int complaintId);
  Future<List<ComplaintMessage>> getComplaintMessages(int complaintId);
  Future<Complaint> createComplaint({
    required String type,
    required String subject,
    required String description,
    int? orderId,
    String? priority,
  });
  Future<ComplaintMessage> addComplaintMessage(int complaintId, String message);
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient _apiClient;

  SupportRemoteDataSourceImpl(this._apiClient);

  // ==================== CONTACT INFO ====================

  @override
  Future<ContactInfo> getContactInfo() async {
    final response = await _apiClient.get('support/contact');
    return ContactInfo.fromJson(response.data['data']);
  }

  // ==================== FAQs ====================

  @override
  Future<List<Faq>> getFaqs({String? category, String? search}) async {
    final params = <String, dynamic>{};
    if (category != null && category != 'all') {
      params['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await _apiClient.get('support/faqs', queryParameters: params);
    final List<dynamic> faqsJson = response.data['data']['faqs'] ?? [];
    return faqsJson.map((json) => Faq.fromJson(json)).toList();
  }

  @override
  Future<void> viewFaq(int faqId) async {
    await _apiClient.post('support/faqs/$faqId/view');
  }

  // ==================== CHAT SUPPORT ====================

  @override
  Future<List<SupportChat>> getChats() async {
    final response = await _apiClient.get('support/chats');
    final List<dynamic> chatsJson = response.data['data']['chats'] ?? [];
    return chatsJson.map((json) => SupportChat.fromJson(json)).toList();
  }

  @override
  Future<SupportChat> getOrCreateChat({String? subject}) async {
    final response = await _apiClient.post(
      'support/chats',
      data: subject != null ? {'subject': subject} : null,
    );
    return SupportChat.fromJson(response.data['data']);
  }

  @override
  Future<List<ChatMessage>> getChatMessages(int chatId) async {
    final response = await _apiClient.get('support/chats/$chatId/messages');
    final List<dynamic> messagesJson = response.data['data']['messages'] ?? [];
    return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
  }

  @override
  Future<ChatMessage> sendChatMessage(int chatId, String message) async {
    final response = await _apiClient.post(
      'support/chats/$chatId/messages',
      data: {'message': message},
    );
    return ChatMessage.fromJson(response.data['data']);
  }

  @override
  Future<SupportChat> closeChat(int chatId) async {
    final response = await _apiClient.post('support/chats/$chatId/close');
    return SupportChat.fromJson(response.data['data']);
  }

  // ==================== COMPLAINTS ====================

  @override
  Future<List<Complaint>> getComplaints() async {
    final response = await _apiClient.get('support/complaints');
    final List<dynamic> complaintsJson = response.data['data']['complaints'] ?? [];
    return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
  }

  @override
  Future<Complaint> getComplaintDetails(int complaintId) async {
    final response = await _apiClient.get('support/complaints/$complaintId');
    return Complaint.fromJson(response.data['data']['complaint']);
  }

  @override
  Future<List<ComplaintMessage>> getComplaintMessages(int complaintId) async {
    final response = await _apiClient.get('support/complaints/$complaintId');
    final List<dynamic> messagesJson = response.data['data']['messages'] ?? [];
    return messagesJson.map((json) => ComplaintMessage.fromJson(json)).toList();
  }

  @override
  Future<Complaint> createComplaint({
    required String type,
    required String subject,
    required String description,
    int? orderId,
    String? priority,
  }) async {
    final response = await _apiClient.post(
      'support/complaints',
      data: {
        'type': type,
        'subject': subject,
        'description': description,
        if (orderId != null) 'order_id': orderId,
        if (priority != null) 'priority': priority,
      },
    );
    return Complaint.fromJson(response.data['data']);
  }

  @override
  Future<ComplaintMessage> addComplaintMessage(int complaintId, String message) async {
    final response = await _apiClient.post(
      'support/complaints/$complaintId/messages',
      data: {'message': message},
    );
    return ComplaintMessage.fromJson(response.data['data']);
  }
}
