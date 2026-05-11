import '../entities/contact_info.dart';
import '../entities/faq.dart';
import '../entities/support_chat.dart';
import '../entities/complaint.dart';

abstract class SupportRepositoryInterface {
  Future<ContactInfo> getContactInfo();
  Future<List<Faq>> getFaqs({String? category, String? search});
  Future<void> viewFaq(int faqId);
  Future<List<SupportChat>> getChats();
  Future<SupportChat> getOrCreateChat({String? subject});
  Future<List<ChatMessage>> getChatMessages(int chatId);
  Future<ChatMessage> sendChatMessage(int chatId, String message);
  Future<SupportChat> closeChat(int chatId);
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
