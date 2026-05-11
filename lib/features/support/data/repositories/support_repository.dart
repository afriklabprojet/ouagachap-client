import '../../domain/entities/contact_info.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/support_chat.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepository implements SupportRepositoryInterface {
  final SupportRemoteDataSource _remoteDataSource;

  SupportRepository(this._remoteDataSource);

  // ==================== CONTACT INFO ====================

  @override
  Future<ContactInfo> getContactInfo() async {
    return await _remoteDataSource.getContactInfo();
  }

  // ==================== FAQs ====================

  @override
  Future<List<Faq>> getFaqs({String? category, String? search}) async {
    return await _remoteDataSource.getFaqs(category: category, search: search);
  }

  @override
  Future<void> viewFaq(int faqId) async {
    await _remoteDataSource.viewFaq(faqId);
  }

  // ==================== CHAT SUPPORT ====================

  @override
  Future<List<SupportChat>> getChats() async {
    return await _remoteDataSource.getChats();
  }

  @override
  Future<SupportChat> getOrCreateChat({String? subject}) async {
    return await _remoteDataSource.getOrCreateChat(subject: subject);
  }

  @override
  Future<List<ChatMessage>> getChatMessages(int chatId) async {
    return await _remoteDataSource.getChatMessages(chatId);
  }

  @override
  Future<ChatMessage> sendChatMessage(int chatId, String message) async {
    return await _remoteDataSource.sendChatMessage(chatId, message);
  }

  @override
  Future<SupportChat> closeChat(int chatId) async {
    return await _remoteDataSource.closeChat(chatId);
  }

  // ==================== COMPLAINTS ====================

  @override
  Future<List<Complaint>> getComplaints() async {
    return await _remoteDataSource.getComplaints();
  }

  @override
  Future<Complaint> getComplaintDetails(int complaintId) async {
    return await _remoteDataSource.getComplaintDetails(complaintId);
  }

  @override
  Future<List<ComplaintMessage>> getComplaintMessages(int complaintId) async {
    return await _remoteDataSource.getComplaintMessages(complaintId);
  }

  @override
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

  @override
  Future<ComplaintMessage> addComplaintMessage(
    int complaintId,
    String message,
  ) async {
    return await _remoteDataSource.addComplaintMessage(complaintId, message);
  }
}
