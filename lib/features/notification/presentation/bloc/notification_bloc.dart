import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications, transformer: restartable());
    on<MarkAsRead>(_onMarkAsRead, transformer: droppable());
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded || event.refresh) {
      emit(NotificationLoading());
    }

    try {
      final notifications = await getNotificationsUseCase.call();
      if (isClosed) return;
      final unreadCount = notifications.where((n) => !n.isRead).length; 
      
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      try {
        await markNotificationReadUseCase.call(event.id);
        if (isClosed) return;
        
        // Rafraîchir la liste depuis le serveur
        if (!isClosed) {
          add(const LoadNotifications());
        }
      } catch (e) {
        // Erreur silencieuse ou notification via BlocListener
      }
    }
  }
}
