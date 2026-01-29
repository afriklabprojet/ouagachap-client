import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/support_repository.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository _repository;

  SupportBloc(this._repository) : super(const SupportState()) {
    on<LoadContactInfo>(_onLoadContactInfo);
    on<LoadFaqs>(_onLoadFaqs);
    on<ViewFaq>(_onViewFaq);
    on<ChangeFaqCategory>(_onChangeFaqCategory);
    on<SearchFaqs>(_onSearchFaqs);
    on<LoadChats>(_onLoadChats);
    on<OpenChat>(_onOpenChat);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendChatMessage>(_onSendChatMessage);
    on<CloseChat>(_onCloseChat);
    on<LoadComplaints>(_onLoadComplaints);
    on<LoadComplaintDetails>(_onLoadComplaintDetails);
    on<CreateComplaint>(_onCreateComplaint);
    on<AddComplaintMessage>(_onAddComplaintMessage);
    on<ResetSupportState>(_onResetSupportState);
    on<ClearSupportError>(_onClearSupportError);
  }

  // ==================== CONTACT INFO ====================

  Future<void> _onLoadContactInfo(
    LoadContactInfo event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(status: SupportStatus.loading));
      final contactInfo = await _repository.getContactInfo();
      emit(state.copyWith(
        status: SupportStatus.success,
        contactInfo: contactInfo,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.failure,
        errorMessage: 'Erreur lors du chargement des contacts: $e',
      ));
    }
  }

  // ==================== FAQs ====================

  Future<void> _onLoadFaqs(
    LoadFaqs event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(faqsLoading: true));
      final faqs = await _repository.getFaqs(
        category: event.category ?? state.selectedFaqCategory,
        search: event.search ?? state.faqSearchQuery,
      );
      emit(state.copyWith(
        faqs: faqs,
        faqsLoading: false,
        status: SupportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        faqsLoading: false,
        status: SupportStatus.failure,
        errorMessage: 'Erreur lors du chargement des FAQs: $e',
      ));
    }
  }

  Future<void> _onViewFaq(
    ViewFaq event,
    Emitter<SupportState> emit,
  ) async {
    try {
      await _repository.viewFaq(event.faqId);
    } catch (_) {
      // Ignorer les erreurs de vue
    }
  }

  Future<void> _onChangeFaqCategory(
    ChangeFaqCategory event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(selectedFaqCategory: event.category));
    add(LoadFaqs(category: event.category));
  }

  Future<void> _onSearchFaqs(
    SearchFaqs event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(faqSearchQuery: event.query));
    add(LoadFaqs(search: event.query));
  }

  // ==================== CHAT ====================

  Future<void> _onLoadChats(
    LoadChats event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(chatLoading: true));
      final chats = await _repository.getChats();
      emit(state.copyWith(
        chats: chats,
        chatLoading: false,
        status: SupportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        chatLoading: false,
        status: SupportStatus.failure,
        errorMessage: 'Erreur lors du chargement des conversations: $e',
      ));
    }
  }

  Future<void> _onOpenChat(
    OpenChat event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(chatLoading: true));
      final chat = await _repository.getOrCreateChat(subject: event.subject);
      final messages = await _repository.getChatMessages(chat.id);
      emit(state.copyWith(
        currentChat: chat,
        chatMessages: messages,
        chatLoading: false,
        status: SupportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        chatLoading: false,
        status: SupportStatus.failure,
        errorMessage: 'Erreur lors de l\'ouverture du chat: $e',
      ));
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(chatLoading: true));
      final messages = await _repository.getChatMessages(event.chatId);
      emit(state.copyWith(
        chatMessages: messages,
        chatLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        chatLoading: false,
        errorMessage: 'Erreur lors du chargement des messages: $e',
      ));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(sendingMessage: true));
      final message = await _repository.sendChatMessage(event.chatId, event.message);
      final updatedMessages = [...state.chatMessages, message];
      emit(state.copyWith(
        chatMessages: updatedMessages,
        sendingMessage: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        sendingMessage: false,
        errorMessage: 'Erreur lors de l\'envoi du message: $e',
      ));
    }
  }

  Future<void> _onCloseChat(
    CloseChat event,
    Emitter<SupportState> emit,
  ) async {
    try {
      await _repository.closeChat(event.chatId);
      add(LoadChats());
      emit(state.copyWith(clearCurrentChat: true));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Erreur lors de la fermeture du chat: $e',
      ));
    }
  }

  // ==================== COMPLAINTS ====================

  Future<void> _onLoadComplaints(
    LoadComplaints event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(complaintsLoading: true));
      final complaints = await _repository.getComplaints();
      emit(state.copyWith(
        complaints: complaints,
        complaintsLoading: false,
        status: SupportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        complaintsLoading: false,
        status: SupportStatus.failure,
        errorMessage: 'Erreur lors du chargement des réclamations: $e',
      ));
    }
  }

  Future<void> _onLoadComplaintDetails(
    LoadComplaintDetails event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(complaintsLoading: true));
      final complaint = await _repository.getComplaintDetails(event.complaintId);
      final messages = await _repository.getComplaintMessages(event.complaintId);
      emit(state.copyWith(
        currentComplaint: complaint,
        complaintMessages: messages,
        complaintsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        complaintsLoading: false,
        errorMessage: 'Erreur lors du chargement de la réclamation: $e',
      ));
    }
  }

  Future<void> _onCreateComplaint(
    CreateComplaint event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(creatingComplaint: true));
      final complaint = await _repository.createComplaint(
        type: event.type,
        subject: event.subject,
        description: event.description,
        orderId: event.orderId,
        priority: event.priority,
      );
      final updatedComplaints = [complaint, ...state.complaints];
      emit(state.copyWith(
        complaints: updatedComplaints,
        currentComplaint: complaint,
        creatingComplaint: false,
        status: SupportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        creatingComplaint: false,
        status: SupportStatus.failure,
        errorMessage: 'Erreur lors de la création de la réclamation: $e',
      ));
    }
  }

  Future<void> _onAddComplaintMessage(
    AddComplaintMessage event,
    Emitter<SupportState> emit,
  ) async {
    try {
      emit(state.copyWith(sendingMessage: true));
      final message = await _repository.addComplaintMessage(event.complaintId, event.message);
      final updatedMessages = [...state.complaintMessages, message];
      emit(state.copyWith(
        complaintMessages: updatedMessages,
        sendingMessage: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        sendingMessage: false,
        errorMessage: 'Erreur lors de l\'envoi du message: $e',
      ));
    }
  }

  // ==================== RESET ====================

  Future<void> _onResetSupportState(
    ResetSupportState event,
    Emitter<SupportState> emit,
  ) async {
    emit(const SupportState());
  }

  Future<void> _onClearSupportError(
    ClearSupportError event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
  }
}
