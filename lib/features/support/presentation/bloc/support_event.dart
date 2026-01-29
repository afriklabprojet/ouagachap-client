import 'package:equatable/equatable.dart';

abstract class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => [];
}

// ==================== CONTACT INFO EVENTS ====================

class LoadContactInfo extends SupportEvent {}

// ==================== FAQ EVENTS ====================

class LoadFaqs extends SupportEvent {
  final String? category;
  final String? search;

  const LoadFaqs({this.category, this.search});

  @override
  List<Object?> get props => [category, search];
}

class ViewFaq extends SupportEvent {
  final int faqId;

  const ViewFaq(this.faqId);

  @override
  List<Object?> get props => [faqId];
}

class ChangeFaqCategory extends SupportEvent {
  final String category;

  const ChangeFaqCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchFaqs extends SupportEvent {
  final String query;

  const SearchFaqs(this.query);

  @override
  List<Object?> get props => [query];
}

// ==================== CHAT EVENTS ====================

class LoadChats extends SupportEvent {}

class OpenChat extends SupportEvent {
  final String? subject;

  const OpenChat({this.subject});

  @override
  List<Object?> get props => [subject];
}

class LoadChatMessages extends SupportEvent {
  final int chatId;

  const LoadChatMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class SendChatMessage extends SupportEvent {
  final int chatId;
  final String message;

  const SendChatMessage(this.chatId, this.message);

  @override
  List<Object?> get props => [chatId, message];
}

class CloseChat extends SupportEvent {
  final int chatId;

  const CloseChat(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

// ==================== COMPLAINT EVENTS ====================

class LoadComplaints extends SupportEvent {}

class LoadComplaintDetails extends SupportEvent {
  final int complaintId;

  const LoadComplaintDetails(this.complaintId);

  @override
  List<Object?> get props => [complaintId];
}

class CreateComplaint extends SupportEvent {
  final String type;
  final String subject;
  final String description;
  final int? orderId;
  final String? priority;

  const CreateComplaint({
    required this.type,
    required this.subject,
    required this.description,
    this.orderId,
    this.priority,
  });

  @override
  List<Object?> get props => [type, subject, description, orderId, priority];
}

class AddComplaintMessage extends SupportEvent {
  final int complaintId;
  final String message;

  const AddComplaintMessage(this.complaintId, this.message);

  @override
  List<Object?> get props => [complaintId, message];
}

// ==================== RESET EVENTS ====================

class ResetSupportState extends SupportEvent {}

class ClearSupportError extends SupportEvent {}
