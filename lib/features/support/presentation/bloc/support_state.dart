import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_info.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/support_chat.dart';
import '../../domain/entities/complaint.dart';

enum SupportStatus { initial, loading, success, failure }

class SupportState extends Equatable {
  // General
  final SupportStatus status;
  final String? errorMessage;

  // Contact Info
  final ContactInfo? contactInfo;

  // FAQs
  final List<Faq> faqs;
  final String selectedFaqCategory;
  final String faqSearchQuery;
  final bool faqsLoading;

  // Chat
  final List<SupportChat> chats;
  final SupportChat? currentChat;
  final List<ChatMessage> chatMessages;
  final bool chatLoading;
  final bool sendingMessage;

  // Complaints
  final List<Complaint> complaints;
  final Complaint? currentComplaint;
  final List<ComplaintMessage> complaintMessages;
  final bool complaintsLoading;
  final bool creatingComplaint;

  const SupportState({
    this.status = SupportStatus.initial,
    this.errorMessage,
    this.contactInfo,
    this.faqs = const [],
    this.selectedFaqCategory = 'all',
    this.faqSearchQuery = '',
    this.faqsLoading = false,
    this.chats = const [],
    this.currentChat,
    this.chatMessages = const [],
    this.chatLoading = false,
    this.sendingMessage = false,
    this.complaints = const [],
    this.currentComplaint,
    this.complaintMessages = const [],
    this.complaintsLoading = false,
    this.creatingComplaint = false,
  });

  bool get hasOpenChat => chats.any((chat) => chat.isOpen);

  int get totalUnreadMessages {
    int chatUnread = chats.fold(0, (sum, chat) => sum + chat.unreadCount);
    int complaintUnread = complaints.fold(0, (sum, c) => sum + c.unreadCount);
    return chatUnread + complaintUnread;
  }

  SupportState copyWith({
    SupportStatus? status,
    String? errorMessage,
    ContactInfo? contactInfo,
    List<Faq>? faqs,
    String? selectedFaqCategory,
    String? faqSearchQuery,
    bool? faqsLoading,
    List<SupportChat>? chats,
    SupportChat? currentChat,
    List<ChatMessage>? chatMessages,
    bool? chatLoading,
    bool? sendingMessage,
    List<Complaint>? complaints,
    Complaint? currentComplaint,
    List<ComplaintMessage>? complaintMessages,
    bool? complaintsLoading,
    bool? creatingComplaint,
    bool clearError = false,
    bool clearCurrentChat = false,
    bool clearCurrentComplaint = false,
  }) {
    return SupportState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      contactInfo: contactInfo ?? this.contactInfo,
      faqs: faqs ?? this.faqs,
      selectedFaqCategory: selectedFaqCategory ?? this.selectedFaqCategory,
      faqSearchQuery: faqSearchQuery ?? this.faqSearchQuery,
      faqsLoading: faqsLoading ?? this.faqsLoading,
      chats: chats ?? this.chats,
      currentChat: clearCurrentChat ? null : (currentChat ?? this.currentChat),
      chatMessages: chatMessages ?? this.chatMessages,
      chatLoading: chatLoading ?? this.chatLoading,
      sendingMessage: sendingMessage ?? this.sendingMessage,
      complaints: complaints ?? this.complaints,
      currentComplaint: clearCurrentComplaint ? null : (currentComplaint ?? this.currentComplaint),
      complaintMessages: complaintMessages ?? this.complaintMessages,
      complaintsLoading: complaintsLoading ?? this.complaintsLoading,
      creatingComplaint: creatingComplaint ?? this.creatingComplaint,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        contactInfo,
        faqs,
        selectedFaqCategory,
        faqSearchQuery,
        faqsLoading,
        chats,
        currentChat,
        chatMessages,
        chatLoading,
        sendingMessage,
        complaints,
        currentComplaint,
        complaintMessages,
        complaintsLoading,
        creatingComplaint,
      ];
}
