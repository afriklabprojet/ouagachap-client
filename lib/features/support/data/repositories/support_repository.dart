import '../../domain/entities/contact_info.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/support_chat.dart';
import '../../domain/entities/complaint.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepository {
  final SupportRemoteDataSource _remoteDataSource;

  SupportRepository(this._remoteDataSource);

  // ==================== CONTACT INFO ====================

  Future<ContactInfo> getContactInfo() async {
    return await _remoteDataSource.getContactInfo();
  }

  // ==================== FAQs ====================

  Future<List<Faq>> getFaqs({String? category, String? search}) async {
    return await _remoteDataSource.getFaqs(category: category, search: search);
  }

  Future<void> viewFaq(int faqId) async {
    await _remoteDataSource.viewFaq(faqId);
  }

  // ==================== CHAT SUPPORT ====================

  Future<List<SupportChat>> getChats() async {
    return await _remoteDataSource.getChats();
  }

  Future<SupportChat> getOrCreateChat({String? subject}) async {
    return await _remoteDataSource.getOrCreateChat(subject: subject);
  }

  Future<List<ChatMessage>> getChatMessages(int chatId) async {
    return await _remoteDataSource.getChatMessages(chatId);
  }

  Future<ChatMessage> sendChatMessage(int chatId, String message) async {
    return await _remoteDataSource.sendChatMessage(chatId, message);
  }

  Future<SupportChat> closeChat(int chatId) async {
    return await _remoteDataSource.closeChat(chatId);
  }

  // ==================== COMPLAINTS ====================

  Future<List<Complaint>> getComplaints() async {
    return await _remoteDataSource.getComplaints();
  }

  Future<Complaint> getComplaintDetails(int complaintId) async {
    return await _remoteDataSource.getComplaintDetails(complaintId);
  }

  Future<List<ComplaintMessage>> getComplaintMessages(int complaintId) async {
    return await _remoteDataSource.getComplaintMessages(complaintId);
  }

  Future<Complaint> createComplaint({
    required String type,
    required String subject,
    required String description,
    int? orderId,
    String? priority,
  }) async {
    return await _remoteDataSource.createComplaint(
      type: type,
      subject: subject,
      description: description,
      orderId: orderId,
      priority: priority,
    );
  }

  Future<ComplaintMessage> addComplaintMessage(int complaintId, String message) async {
    return await _remoteDataSource.addComplaintMessage(complaintId, message);
  }
}
